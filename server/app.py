from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS

import subprocess
import os
import json
import shutil


app = Flask(__name__)
CORS(app)


# ============================================================
# PROJECT PATHS
# ============================================================

PROJECT_DIR = os.path.dirname(
    os.path.dirname(
        os.path.abspath(__file__)
    )
)

SERVER_DIR = os.path.join(
    PROJECT_DIR,
    "server"
)

GUI_DIR = os.path.join(
    PROJECT_DIR,
    "gui"
)

API_PROLOG = os.path.join(
    PROJECT_DIR,
    "chess_expert.pl"
)


# ============================================================
# SWI-PROLOG
# ============================================================

SWIPL = shutil.which("swipl")

if SWIPL is None:
    possible_path = r"C:\Program Files\swipl\bin\swipl.exe"

    if os.path.exists(possible_path):
        SWIPL = possible_path


# ============================================================
# RUN PROLOG
# ============================================================

def run_prolog(payload):

    if SWIPL is None:
        return {
            "success": False,
            "error_code": "SWIPL_NOT_FOUND"
        }

    if not os.path.exists(API_PROLOG):
        return {
            "success": False,
            "error_code": "API_PROLOG_NOT_FOUND"
        }

    try:

        process = subprocess.run(
            [
                SWIPL,
                "-q",
                "-s",
                API_PROLOG,
                "-g",
                "chess_expert:api_main",
                "-t",
                "halt"
            ],
            input=json.dumps(payload),
            text=True,
            capture_output=True,
            cwd=PROJECT_DIR,
            timeout=15
        )

    except subprocess.TimeoutExpired:

        return {
            "success": False,
            "error_code": "PROLOG_TIMEOUT"
        }

    except Exception as error:

        return {
            "success": False,
            "error_code": "PROLOG_EXECUTION_ERROR",
            "error": str(error)
        }


    if process.returncode != 0:

        return {
            "success": False,
            "error_code": "PROLOG_PROCESS_ERROR",
            "error": process.stderr.strip()
        }


    output = process.stdout.strip()

    if not output:

        return {
            "success": False,
            "error_code": "EMPTY_PROLOG_RESPONSE",
            "error": process.stderr.strip()
        }


    try:

        return json.loads(output)

    except json.JSONDecodeError:

        return {
            "success": False,
            "error_code": "INVALID_PROLOG_JSON",
            "raw_output": output,
            "error": process.stderr.strip()
        }

# ============================================================
# GUI
# ============================================================

@app.route("/gui/", methods=["GET"])
def gui_home():

    return send_from_directory(
        GUI_DIR,
        "index.html"
    )


@app.route("/gui/<path:filename>", methods=["GET"])
def serve_gui(filename):

    return send_from_directory(
        GUI_DIR,
        filename
    )


# ============================================================
# BASIC API
# ============================================================

@app.route("/", methods=["GET"])
def home():

    return jsonify({
        "success": True
    })


# ============================================================
# PROLOG UI DATA
# ============================================================

@app.route("/ui", methods=["GET"])
def ui():

    result = run_prolog({
        "request": "config"
    })

    return jsonify({
        "success": True,
        "data": result
    }), 200


@app.route("/config", methods=["GET"])
def config():

    result = run_prolog({
        "request": "config"
    })

    return jsonify({
        "success": True,
        "data": result
    }), 200

# ============================================================
# PROLOG ANALYSIS
# ============================================================

@app.route("/analyze", methods=["POST"])
def analyze():

    data = request.get_json(
        silent=True
    )

    if not isinstance(data, dict):

        return jsonify({
            "success": False,
            "error_code": "INVALID_REQUEST"
        }), 400

    data["request"] = "analyze"

    result = run_prolog(data)

    return jsonify(result), 200

# ============================================================
# PROLOG TEST
# ============================================================

@app.route("/test-prolog", methods=["GET"])
def test_prolog():

    result = run_prolog({
        "request": "test"
    })

    status_code = 200 if result.get("success") else 500

    return jsonify(result), status_code


# ============================================================
# ERROR HANDLER
# ============================================================

@app.errorhandler(Exception)
def handle_exception(error):

    return jsonify({
        "success": False,
        "error_code": "SERVER_ERROR"
    }), 500


# ============================================================
# START SERVER
# ============================================================

if __name__ == "__main__":

    app.run(
        host="127.0.0.1",
        port=5000,
        debug=True
    )