# Beginner Chess Strategy Advisor Expert System

A beginner-level chess expert system that analyzes a chess position based on user-provided information and recommends an appropriate strategic action. The system is implemented using **SWI-Prolog** for knowledge representation and inference, with a **Flask** backend and a browser-based web interface.

## Project Overview

The **Beginner Chess Strategy Advisor Expert System** is designed to provide strategic recommendations to beginner chess players based on common chess principles.

The system collects information about the current chess position through a web-based questionnaire. The answers are converted into Prolog facts and evaluated against a knowledge base containing **30 facts and 30 production rules**.

The system then selects a recommendation according to a predefined rule-priority mechanism and provides an explanation describing why the recommendation was selected.

## Main Features

* Beginner-friendly chess position analysis
* 30 knowledge-base fact predicates
* 30 production rules
* Rule-priority based inference
* Backward-chaining-style reasoning
* Explanation facility showing why a recommendation was selected
* Browser-based questionnaire interface
* Flask backend for communication between the web interface and Prolog
* Prolog-based knowledge representation
* JSON communication between the Flask server and Prolog
* Supports strategic recommendations such as:

  * Develop a piece
  * Defend immediately
  * Protect a piece
  * Castle
  * Improve king safety
  * Check
  * Fork
  * Pin
  * Attack
  * Simplify
  * Improve the worst piece
  * Improve pawn structure
  * Control a key square
  * Make a useful move

## Technologies Used

| Technology | Purpose                                          |
| ---------- | ------------------------------------------------ |
| SWI-Prolog | Knowledge representation and inference engine    |
| Python     | Backend integration                              |
| Flask      | Web server and Prolog integration                |
| HTML       | Web interface structure                          |
| CSS        | User interface styling                           |
| JavaScript | Client-side interaction                          |
| JSON       | Communication between frontend, Flask and Prolog |


## How the System Works

The general workflow is:

```text
Start
  |
  v
Display Chess Position Questions
  |
  v
User Provides Answers
  |
  v
Flask Receives Answers
  |
  v
Convert Answers into Prolog Facts
  |
  v
Evaluate Knowledge Base Rules
  |
  v
Apply Rule Priority
  |
  v
Select Recommendation
  |
  v
Generate Explanation
  |
  v
Return Result to Web Interface
  |
  v
Display Recommendation and Reasoning
  |
  v
End
```

## Knowledge Base

The knowledge base represents important chess-position characteristics.

The system contains **30 fact predicates** and **30 production rules** representing beginner-level chess principles.

## Inference Engine

The inference engine evaluates the facts describing the current position against the available rules.

The rules are evaluated according to a predefined priority order. This allows the system to address more urgent situations, such as immediate threats or tactical opportunities, before considering general positional improvements.

The system also uses Prolog's cut mechanism where appropriate to ensure that once a higher-priority recommendation is selected, lower-priority alternatives are not unnecessarily considered.

## Explanation Facility

In addition to producing a recommendation, the system explains the reasoning behind the selected action.

## User Interface

The system provides a browser-based interface where the user answers questions about the current chess position.

The interface collects information such as:

* King safety
* Castling rights
* Piece development
* Tactical opportunities
* Material balance
* Positional characteristics

After submitting the answers, the system displays the recommended chess action together with an explanation.

### Main Files

**`chess_expert.pl`**
Main Prolog entry point for the expert system.

**`knowledge_base.pl`**
Contains the chess facts and knowledge represented as Prolog predicates.

**`inference_engine.pl`**
Contains the recommendation rules, rule-priority mechanism and explanation logic.

**`ui_knowledge.pl`**
Contains knowledge used by the user interface.

**`server/app.py`**
Flask backend responsible for communicating with the browser interface and the Prolog application.

**`gui/`**
Contains the browser-based user interface.

## Installation and Setup

### Requirements

Make sure the following software is installed:

* Python 3.x
* SWI-Prolog
* A modern web browser

### 1. Clone the Repository

```bash
git clone https://github.com/Mihisararl/Beginner-Chess-Strategy-Advisor.git
```

Then enter the project directory:

```bash
cd Beginner-Chess-Strategy-Advisor
```

### 2. Install Flask

Install Flask using:

```bash
pip install flask
```

If the project contains a `requirements.txt` file, install the dependencies using:

```bash
pip install -r requirements.txt
```

### 3. Verify SWI-Prolog

Make sure SWI-Prolog is installed and available on your system.

You can verify the installation with:

```bash
swipl --version
```

## Running the Application

From the project root directory, start the Flask server:

```bash
python server/app.py
```

The application will be available at:

```text
http://127.0.0.1:5000/gui/
```

Open the URL in a web browser to use the expert system.

## Testing

The expert system was tested using **14 test cases** covering different chess scenarios, including:

* Piece development
* Protecting an attacked piece
* Immediate threats
* Castling
* King safety
* Check
* Fork
* Pin
* Simplifying when ahead in material
* Improving an inactive piece
* Improving pawn structure
* Controlling a key square
* Attacking an opponent's weakness
* Making a useful move when no higher-priority condition applies

The tests were used to verify that the appropriate recommendation was produced for each scenario and that the explanation matched the activated rule.

## Scope and Limitations

The system is intended for **beginner-level strategic guidance** rather than complete chess analysis.

It does not replace a full chess engine and does not calculate every possible legal move or variation on a chess board.

The recommendations depend on the information supplied by the user through the questionnaire. Therefore, the quality of the recommendation depends on the accuracy of the provided position information.

## Academic Context

**Project:** Beginner Chess Strategy Advisor Expert System

**Domain:** Chess strategy and beginner decision support

**Implementation:** SWI-Prolog, Flask, HTML, CSS and JavaScript

**Knowledge Base:** 30 fact predicates and 30 production rules

**Inference:** Priority-based backward-chaining-style reasoning

**Interface:** Browser-based questionnaire and recommendation interface

## Author

**R.L. Mihisara**

University of Moratuwa
Faculty of Information Technology

## Repository

GitHub repository:

https://github.com/Mihisararl/Beginner-Chess-Strategy-Advisor.git
