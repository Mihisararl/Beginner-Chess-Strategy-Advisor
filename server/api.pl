:- module(api, [
    main/0
]).

:- use_module(library(json)).
:- use_module('../knowledge_base').
:- use_module('../inference_engine').
:- use_module('../ui_knowledge').


% ============================================================
% MAIN
% ============================================================

main :-
    catch(
        (
            json_read_dict(
                current_input,
                Request
            ),
            handle_request(
                Request,
                Response
            ),
            json_write_dict(
                current_output,
                Response
            ),
            nl
        ),
        Error,
        handle_error(Error)
    ).


% ============================================================
% REQUEST DISPATCH
% ============================================================

handle_request(
    Request,
    Response
) :-
    get_dict(
        mode,
        Request,
        Mode
    ),
    handle_mode(
        Mode,
        Request,
        Response
    ).


% ============================================================
% UI MODE
% ============================================================

handle_mode(
    "ui",
    _Request,
    Response
) :-
    capture_ui_data(
        UIData
    ),

    Response = _{
        success: true,
        data: UIData
    }.


% ============================================================
% ANALYZE MODE
% ============================================================

handle_mode(
    "analyze",
    Request,
    Response
) :-
    knowledge_base:clear_facts,

    apply_answers(
        Request
    ),

    inference_engine:recommend(
        Action
    ),

    get_reasoning(
        Action,
        Rules
    ),

    ui_knowledge:recommendation_info(
        Action,
        Recommendation
    ),

    ui_knowledge:reasoning_info(
        Action,
        Reasoning
    ),

    knowledge_base:all_facts(
        Facts
    ),

    Response = _{
        success: true,
        recommendation: Action,
        recommendationInfo: Recommendation,
        reasoning: Reasoning,
        rules: Rules,
        facts: Facts
    }.


% ============================================================
% TEST MODE
% ============================================================

handle_mode(
    "test",
    _Request,
    Response
) :-
    Response = _{
        success: true,
        message: "Prolog API is working"
    }.


% ============================================================
% UNKNOWN MODE
% ============================================================

handle_mode(
    Mode,
    _Request,
    Response
) :-
    Response = _{
        success: false,
        error_code: "UNKNOWN_MODE",
        mode: Mode
    }.


% ============================================================
% CAPTURE UI DATA
% ============================================================

capture_ui_data(UIData) :-
    with_output_to(
        string(JSONString),
        ui_knowledge:ui_data
    ),
    open_string(
        JSONString,
        Stream
    ),
    json_read_dict(
        Stream,
        UIData
    ),
    close(Stream).


% ============================================================
% APPLY GUI ANSWERS
% ============================================================

apply_answers(
    Request
) :-

    get_value(
        Request,
        kingSafety,
        KingSafety
    ),

    apply_king_safety(
        KingSafety,
        Request
    ),

    get_value(
        Request,
        development,
        Development
    ),

    apply_development(
        Development
    ),

    get_value(
        Request,
        tactical,
        Tactical
    ),

    apply_tactical(
        Tactical,
        Request
    ),

    get_value(
        Request,
        material,
        Material
    ),

    apply_material(
        Material
    ),

    get_value(
        Request,
        position,
        Position
    ),

    apply_position(
        Position,
        Request
    ),

    add_common_facts.


% ============================================================
% GET VALUE
% ============================================================

get_value(
    Dict,
    Key,
    Value
) :-
    get_dict(
        Key,
        Dict,
        Value
    ),
    !.

get_value(
    _Dict,
    _Key,
    null
).


% ============================================================
% KING SAFETY
% ============================================================

apply_king_safety(
    "safe_castled",
    _Request
) :-
    assertz(
        knowledge_base:king_safe(yes)
    ),
    assertz(
        knowledge_base:king_castled(yes)
    ),
    assertz(
        knowledge_base:castling_rights(no)
    ),
    assertz(
        knowledge_base:center_status(closed)
    ),
    assertz(
        knowledge_base:opponent_attacking_king(no)
    ),
    assertz(
        knowledge_base:open_lines_to_king(no)
    ),
    assertz(
        knowledge_base:pawn_storm_near_king(no)
    ),
    assertz(
        knowledge_base:sacrifice_against_king(no)
    ).

apply_king_safety(
    "safe_uncastled",
    Request
) :-
    assertz(
        knowledge_base:king_safe(yes)
    ),
    assertz(
        knowledge_base:king_castled(no)
    ),
    get_value(
        Request,
        castlingRights,
        Rights
    ),
    assertz(
        knowledge_base:castling_rights(Rights)
    ),
    assertz(
        knowledge_base:center_status(closed)
    ),
    assertz(
        knowledge_base:opponent_attacking_king(no)
    ),
    assertz(
        knowledge_base:open_lines_to_king(no)
    ),
    assertz(
        knowledge_base:pawn_storm_near_king(no)
    ),
    assertz(
        knowledge_base:sacrifice_against_king(no)
    ).

apply_king_safety(
    "exposed",
    _Request
) :-
    assertz(
        knowledge_base:king_safe(no)
    ),
    assertz(
        knowledge_base:king_castled(no)
    ),
    assertz(
        knowledge_base:castling_rights(no)
    ),
    assertz(
        knowledge_base:center_status(open)
    ),
    assertz(
        knowledge_base:opponent_attacking_king(no)
    ),
    assertz(
        knowledge_base:open_lines_to_king(yes)
    ),
    assertz(
        knowledge_base:pawn_storm_near_king(no)
    ),
    assertz(
        knowledge_base:sacrifice_against_king(no)
    ).

apply_king_safety(
    "under_attack",
    _Request
) :-
    assertz(
        knowledge_base:king_safe(no)
    ),
    assertz(
        knowledge_base:king_castled(no)
    ),
    assertz(
        knowledge_base:castling_rights(no)
    ),
    assertz(
        knowledge_base:center_status(open)
    ),
    assertz(
        knowledge_base:opponent_attacking_king(yes)
    ),
    assertz(
        knowledge_base:open_lines_to_king(yes)
    ),
    assertz(
        knowledge_base:pawn_storm_near_king(no)
    ),
    assertz(
        knowledge_base:sacrifice_against_king(no)
    ).

apply_king_safety(
    _,
    _Request
).


% ============================================================
% DEVELOPMENT
% ============================================================

apply_development(
    "ahead"
) :-
    assertz(
        knowledge_base:own_development(high)
    ),
    assertz(
        knowledge_base:opponent_development(low)
    ),
    assertz(
        knowledge_base:own_minor_pieces_developed(4)
    ),
    assertz(
        knowledge_base:opponent_minor_pieces_developed(2)
    ).

apply_development(
    "equal"
) :-
    assertz(
        knowledge_base:own_development(medium)
    ),
    assertz(
        knowledge_base:opponent_development(medium)
    ),
    assertz(
        knowledge_base:own_minor_pieces_developed(3)
    ),
    assertz(
        knowledge_base:opponent_minor_pieces_developed(3)
    ).

apply_development(
    "behind"
) :-
    assertz(
        knowledge_base:own_development(low)
    ),
    assertz(
        knowledge_base:opponent_development(high)
    ),
    assertz(
        knowledge_base:own_minor_pieces_developed(2)
    ),
    assertz(
        knowledge_base:opponent_minor_pieces_developed(4)
    ).

apply_development(
    _
).


% ============================================================
% TACTICAL SITUATION
% ============================================================

apply_tactical(
    "none",
    _Request
) :-
    assertz(
        knowledge_base:tactical_opportunity(none)
    ),
    assertz(
        knowledge_base:own_piece_attacked(no)
    ),
    assertz(
        knowledge_base:immediate_threat(no)
    ),
    assertz(
        knowledge_base:piece_defended(yes)
    ).

apply_tactical(
    "check",
    _Request
) :-
    assertz(
        knowledge_base:tactical_opportunity(check)
    ),
    assertz(
        knowledge_base:own_piece_attacked(no)
    ),
    assertz(
        knowledge_base:immediate_threat(no)
    ),
    assertz(
        knowledge_base:piece_defended(yes)
    ).

apply_tactical(
    "fork",
    _Request
) :-
    assertz(
        knowledge_base:tactical_opportunity(fork)
    ),
    assertz(
        knowledge_base:own_piece_attacked(no)
    ),
    assertz(
        knowledge_base:immediate_threat(no)
    ),
    assertz(
        knowledge_base:piece_defended(yes)
    ).

apply_tactical(
    "pin",
    _Request
) :-
    assertz(
        knowledge_base:tactical_opportunity(pin)
    ),
    assertz(
        knowledge_base:own_piece_attacked(no)
    ),
    assertz(
        knowledge_base:immediate_threat(no)
    ),
    assertz(
        knowledge_base:piece_defended(yes)
    ).

apply_tactical(
    "piece_attacked",
    Request
) :-
    assertz(
        knowledge_base:tactical_opportunity(none)
    ),
    assertz(
        knowledge_base:own_piece_attacked(yes)
    ),

    get_value(
        Request,
        pieceDefended,
        Defended
    ),

    assertz(
        knowledge_base:piece_defended(Defended)
    ),

    assertz(
        knowledge_base:immediate_threat(no)
    ).

apply_tactical(
    "immediate_threat",
    _Request
) :-
    assertz(
        knowledge_base:tactical_opportunity(none)
    ),
    assertz(
        knowledge_base:own_piece_attacked(no)
    ),
    assertz(
        knowledge_base:piece_defended(yes)
    ),
    assertz(
        knowledge_base:immediate_threat(yes)
    ).

apply_tactical(
    _
).


% ============================================================
% MATERIAL
% ============================================================

apply_material(
    "ahead"
) :-
    assertz(
        knowledge_base:material_status(ahead)
    ),
    assertz(
        knowledge_base:exchange_favorable(yes)
    ).

apply_material(
    "equal"
) :-
    assertz(
        knowledge_base:material_status(equal)
    ),
    assertz(
        knowledge_base:exchange_favorable(no)
    ).

apply_material(
    "behind"
) :-
    assertz(
        knowledge_base:material_status(behind)
    ),
    assertz(
        knowledge_base:exchange_favorable(no)
    ).

apply_material(
    _
).


% ============================================================
% POSITION
% ============================================================

apply_position(
    "weak_pawns",
    _Request
) :-
    assertz(
        knowledge_base:pawn_structure_weak(yes)
    ),
    assertz(
        knowledge_base:worst_piece_inactive(no)
    ),
    assertz(
        knowledge_base:key_square_available(no)
    ),
    assertz(
        knowledge_base:position_has_weaknesses(yes)
    ),
    assertz(
        knowledge_base:opponent_has_more_weaknesses(no)
    ),
    assertz(
        knowledge_base:target_available(no)
    ),
    assertz(
        knowledge_base:future_plan_available(yes)
    ).

apply_position(
    "inactive_piece",
    _Request
) :-
    assertz(
        knowledge_base:pawn_structure_weak(no)
    ),
    assertz(
        knowledge_base:worst_piece_inactive(yes)
    ),
    assertz(
        knowledge_base:key_square_available(no)
    ),
    assertz(
        knowledge_base:position_has_weaknesses(yes)
    ),
    assertz(
        knowledge_base:opponent_has_more_weaknesses(no)
    ),
    assertz(
        knowledge_base:target_available(no)
    ),
    assertz(
        knowledge_base:future_plan_available(yes)
    ).

apply_position(
    "key_square",
    _Request
) :-
    assertz(
        knowledge_base:pawn_structure_weak(no)
    ),
    assertz(
        knowledge_base:worst_piece_inactive(no)
    ),
    assertz(
        knowledge_base:key_square_available(yes)
    ),
    assertz(
        knowledge_base:position_has_weaknesses(no)
    ),
    assertz(
        knowledge_base:opponent_has_more_weaknesses(no)
    ),
    assertz(
        knowledge_base:target_available(no)
    ),
    assertz(
        knowledge_base:future_plan_available(yes)
    ).

apply_position(
    "opponent_weakness",
    Request
) :-
    assertz(
        knowledge_base:pawn_structure_weak(no)
    ),
    assertz(
        knowledge_base:worst_piece_inactive(no)
    ),
    assertz(
        knowledge_base:key_square_available(no)
    ),
    assertz(
        knowledge_base:position_has_weaknesses(no)
    ),
    assertz(
        knowledge_base:target_available(yes)
    ),

    get_value(
        Request,
        attackSupported,
        AttackSupported
    ),

    assertz(
        knowledge_base:attack_supported(AttackSupported)
    ),

    apply_opponent_weakness(
        AttackSupported
    ),

    assertz(
        knowledge_base:future_plan_available(yes)
    ).

apply_position(
    "none",
    _Request
) :-
    assertz(
        knowledge_base:pawn_structure_weak(no)
    ),
    assertz(
        knowledge_base:worst_piece_inactive(no)
    ),
    assertz(
        knowledge_base:key_square_available(no)
    ),
    assertz(
        knowledge_base:position_has_weaknesses(no)
    ),
    assertz(
        knowledge_base:opponent_has_more_weaknesses(no)
    ),
    assertz(
        knowledge_base:target_available(no)
    ),
    assertz(
        knowledge_base:attack_supported(no)
    ),
    assertz(
        knowledge_base:future_plan_available(no)
    ).

apply_position(
    _
).


apply_opponent_weakness(
    "yes"
) :-
    assertz(
        knowledge_base:opponent_has_more_weaknesses(yes)
    ).

apply_opponent_weakness(
    "no"
) :-
    assertz(
        knowledge_base:opponent_has_more_weaknesses(no)
    ).

apply_opponent_weakness(
    _
) :-
    assertz(
        knowledge_base:opponent_has_more_weaknesses(no)
    ).


% ============================================================
% COMMON FACTS
% ============================================================

add_common_facts :-

    assertz(
        knowledge_base:rook_connected(yes)
    ),

    assertz(
        knowledge_base:counterattack_risk(low)
    ),

    assertz(
        knowledge_base:opening_phase(yes)
    ),

    assertz(
        knowledge_base:opponent_best_piece_can_be_traded(no)
    ).


% ============================================================
% REASONING
% ============================================================

get_reasoning(
    Action,
    Rules
) :-
    (
        inference_engine:reasoning(
            Action,
            Rules
        )
    ->
        true
    ;
        Rules = []
    ).


% ============================================================
% ERROR HANDLING
% ============================================================

handle_error(
    _Error
) :-
    Response = _{
        success: false,
        error_code: "PROLOG_API_ERROR"
    },

    json_write_dict(
        current_output,
        Response
    ),

    nl.


% ============================================================
% ENTRY POINT
% ============================================================

:- initialization(
    main,
    main
).