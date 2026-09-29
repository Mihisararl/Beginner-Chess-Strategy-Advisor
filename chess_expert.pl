:- module(chess_expert, [
    main/0,
    api_main/0,
    analyze_answers/2
]).

:- use_module('knowledge_base.pl', []).
:- use_module('inference_engine.pl', []).
:- use_module('ui_knowledge.pl', []).
:- use_module(library(json)).



% ============================================================
% ANALYZE ANSWERS
% ============================================================

analyze_answers(Answers, Recommendation) :-

    knowledge_base:clear_facts,

    derive_facts(Answers),

    inference_engine:recommend(Recommendation).


% ============================================================
% DERIVE PROLOG FACTS FROM USER ANSWERS
% ============================================================

derive_facts(Answers) :-

    derive_king_facts(Answers),
    derive_development_facts(Answers),
    derive_tactical_facts(Answers),
    derive_material_facts(Answers),
    derive_position_facts(Answers).


% ============================================================
% KING SAFETY
% ============================================================

derive_king_facts(Answers) :-

    get_dict(kingSafety, Answers, Value),

    (
        Value = "safe_castled"
        ->
        assertz(knowledge_base:king_safe(yes)),
        assertz(knowledge_base:king_castled(yes)),
        assertz(knowledge_base:center_status(closed))

        ;

        Value = "safe_uncastled"
        ->
        assertz(knowledge_base:king_safe(yes)),
        assertz(knowledge_base:king_castled(no)),
        derive_castling_rights(Answers)

        ;

        Value = "exposed"
        ->
        assertz(knowledge_base:king_safe(no)),
        assertz(knowledge_base:king_castled(no)),
        assertz(knowledge_base:center_status(open)),
        assertz(knowledge_base:open_lines_to_king(yes))

        ;

        Value = "under_attack"
        ->
        assertz(knowledge_base:king_safe(no)),
        assertz(knowledge_base:king_castled(no)),
        assertz(knowledge_base:opponent_attacking_king(yes))

        ;

        true
    ).


derive_castling_rights(Answers) :-

    get_dict(
        castlingRights,
        Answers,
        Value
    ),

    (
        Value = "yes"
        ->
        assertz(
            knowledge_base:castling_rights(yes)
        )

        ;

        Value = "no"
        ->
        assertz(
            knowledge_base:castling_rights(no)
        )

        ;

        true
    ).


% ============================================================
% DEVELOPMENT
% ============================================================

derive_development_facts(Answers) :-

    get_dict(
        development,
        Answers,
        Value
    ),

    (
        Value = "ahead"
        ->
        assertz(
            knowledge_base:own_development(high)
        ),
        assertz(
            knowledge_base:opponent_development(low)
        )

        ;

        Value = "equal"
        ->
        assertz(
            knowledge_base:own_development(medium)
        ),
        assertz(
            knowledge_base:opponent_development(medium)
        )

        ;

        Value = "behind"
        ->
        assertz(
            knowledge_base:own_development(low)
        ),
        assertz(
            knowledge_base:opponent_development(high)
        )

        ;

        true
    ).


% ============================================================
% TACTICAL SITUATION
% ============================================================

derive_tactical_facts(Answers) :-

    get_dict(
        tactical,
        Answers,
        Value
    ),

    (
        Value = "none"
        ->
        assertz(
            knowledge_base:tactical_opportunity(none)
        ),
        assertz(
            knowledge_base:immediate_threat(no)
        )

        ;

        Value = "check"
        ->
        assertz(
            knowledge_base:tactical_opportunity(check)
        ),
        assertz(
            knowledge_base:immediate_threat(no)
        )

        ;

        Value = "fork"
        ->
        assertz(
            knowledge_base:tactical_opportunity(fork)
        ),
        assertz(
            knowledge_base:immediate_threat(no)
        )

        ;

        Value = "pin"
        ->
        assertz(
            knowledge_base:tactical_opportunity(pin)
        ),
        assertz(
            knowledge_base:immediate_threat(no)
        )

        ;

        Value = "piece_attacked"
        ->
        assertz(
            knowledge_base:own_piece_attacked(yes)
        ),
        derive_piece_defence(Answers),
        assertz(
            knowledge_base:immediate_threat(no)
        )

        ;

        Value = "immediate_threat"
        ->
        assertz(
            knowledge_base:immediate_threat(yes)
        )

        ;

        true
    ).


derive_piece_defence(Answers) :-

    get_dict(
        pieceDefended,
        Answers,
        Value
    ),

    (
        Value = "yes"
        ->
        assertz(
            knowledge_base:piece_defended(yes)
        )

        ;

        Value = "no"
        ->
        assertz(
            knowledge_base:piece_defended(no)
        )

        ;

        true
    ).


% ============================================================
% MATERIAL
% ============================================================

derive_material_facts(Answers) :-

    get_dict(
        material,
        Answers,
        Value
    ),

    (
        Value = "ahead"
        ->
        assertz(
            knowledge_base:material_status(ahead)
        )

        ;

        Value = "equal"
        ->
        assertz(
            knowledge_base:material_status(equal)
        )

        ;

        Value = "behind"
        ->
        assertz(
            knowledge_base:material_status(behind)
        )

        ;

        true
    ).


% ============================================================
% POSITION
% ============================================================

derive_position_facts(Answers) :-

    get_dict(
        position,
        Answers,
        Value
    ),

    (
        Value = "weak_pawns"
        ->
        assertz(
            knowledge_base:pawn_structure_weak(yes)
        ),
        assertz(
            knowledge_base:position_has_weaknesses(yes)
        ),
        assertz(
            knowledge_base:future_plan_available(yes)
        )

        ;

        Value = "inactive_piece"
        ->
        assertz(
            knowledge_base:worst_piece_inactive(yes)
        ),
        assertz(
            knowledge_base:future_plan_available(yes)
        )

        ;

        Value = "key_square"
        ->
        assertz(
            knowledge_base:key_square_available(yes)
        ),
        assertz(
            knowledge_base:future_plan_available(yes)
        )

        ;

        Value = "opponent_weakness"
        ->
        assertz(
            knowledge_base:opponent_has_more_weaknesses(yes)
        ),
        assertz(
            knowledge_base:target_available(yes)
        ),
        derive_attack_support(Answers)

        ;

        Value = "none"
        ->
        assertz(
            knowledge_base:future_plan_available(no)
        )

        ;

        true
    ).


derive_attack_support(Answers) :-

    get_dict(
        attackSupported,
        Answers,
        Value
    ),

    (
        Value = "yes"
        ->
        assertz(
            knowledge_base:attack_supported(yes)
        )

        ;

        Value = "no"
        ->
        assertz(
            knowledge_base:attack_supported(no)
        )

        ;

        true
    ).


% ============================================================
% CONSOLE INTERFACE
% ============================================================

main :-

    knowledge_base:clear_facts,

    nl,
    write('=========================================='), nl,
    write('       Beginner Chess Strategy Advisor'), nl,
    write('=========================================='), nl,
    nl,

    ask_king_safety(KingSafety),

    (
        KingSafety = "safe_uncastled"
        ->
        ask_castling_rights(CastlingRights)
        ;
        CastlingRights = "none"
    ),

    ask_development(Development),

    ask_tactical(Tactical),

    (
        Tactical = "piece_attacked"
        ->
        ask_piece_defended(PieceDefended)
        ;
        PieceDefended = "none"
    ),

    ask_material(Material),

    ask_position(Position),

    (
        Position = "opponent_weakness"
        ->
        ask_attack_supported(AttackSupported)
        ;
        AttackSupported = "none"
    ),

    Answers = _{
        kingSafety: KingSafety,
        castlingRights: CastlingRights,
        development: Development,
        tactical: Tactical,
        pieceDefended: PieceDefended,
        material: Material,
        position: Position,
        attackSupported: AttackSupported
    },

    analyze_answers(
        Answers,
        Recommendation
    ),

    nl,
    write('=========================================='), nl,
    write('RECOMMENDATION: '),
    write(Recommendation),
    nl,
    write('=========================================='), nl.

% ============================================================
% CONSOLE QUESTIONS
% ============================================================

ask_king_safety(Answer) :-

    nl,
    write('How safe is your king?'), nl,
    write('1. Safe and castled'), nl,
    write('2. Safe but uncastled'), nl,
    write('3. Exposed'), nl,
    write('4. Under attack'), nl,

    read(Choice),

    (
        Choice = 1
        ->
        Answer = "safe_castled"

        ;

        Choice = 2
        ->
        Answer = "safe_uncastled"

        ;

        Choice = 3
        ->
        Answer = "exposed"

        ;

        Choice = 4
        ->
        Answer = "under_attack"

        ;

        ask_king_safety(Answer)
    ).


ask_castling_rights(Answer) :-

    nl,
    write('Do you still have castling rights?'), nl,
    write('1. Yes'), nl,
    write('2. No'), nl,

    read(Choice),

    (
        Choice = 1
        ->
        Answer = "yes"

        ;

        Choice = 2
        ->
        Answer = "no"

        ;

        ask_castling_rights(Answer)
    ).


ask_development(Answer) :-

    nl,
    write('How is your piece development?'), nl,
    write('1. Ahead'), nl,
    write('2. Equal'), nl,
    write('3. Behind'), nl,

    read(Choice),

    (
        Choice = 1
        ->
        Answer = "ahead"

        ;

        Choice = 2
        ->
        Answer = "equal"

        ;

        Choice = 3
        ->
        Answer = "behind"

        ;

        ask_development(Answer)
    ).


ask_tactical(Answer) :-

    nl,
    write('What tactical situation exists?'), nl,
    write('1. No immediate tactic'), nl,
    write('2. Check available'), nl,
    write('3. Fork available'), nl,
    write('4. Pin available'), nl,
    write('5. A piece is attacked'), nl,
    write('6. Immediate threat'), nl,

    read(Choice),

    (
        Choice = 1
        ->
        Answer = "none"

        ;

        Choice = 2
        ->
        Answer = "check"

        ;

        Choice = 3
        ->
        Answer = "fork"

        ;

        Choice = 4
        ->
        Answer = "pin"

        ;

        Choice = 5
        ->
        Answer = "piece_attacked"

        ;

        Choice = 6
        ->
        Answer = "immediate_threat"

        ;

        ask_tactical(Answer)
    ).


ask_piece_defended(Answer) :-

    nl,
    write('Is the attacked piece defended?'), nl,
    write('1. Yes'), nl,
    write('2. No'), nl,

    read(Choice),

    (
        Choice = 1
        ->
        Answer = "yes"

        ;

        Choice = 2
        ->
        Answer = "no"

        ;

        ask_piece_defended(Answer)
    ).


ask_material(Answer) :-

    nl,
    write('How is the material balance?'), nl,
    write('1. Material advantage'), nl,
    write('2. Material is equal'), nl,
    write('3. Material disadvantage'), nl,

    read(Choice),

    (
        Choice = 1
        ->
        Answer = "ahead"

        ;

        Choice = 2
        ->
        Answer = "equal"

        ;

        Choice = 3
        ->
        Answer = "behind"

        ;

        ask_material(Answer)
    ).


ask_position(Answer) :-

    nl,
    write('What is the main positional feature?'), nl,
    write('1. Weak pawn structure'), nl,
    write('2. Inactive piece'), nl,
    write('3. Important key square'), nl,
    write('4. Opponent has weaknesses'), nl,
    write('5. No major weakness'), nl,

    read(Choice),

    (
        Choice = 1
        ->
        Answer = "weak_pawns"

        ;

        Choice = 2
        ->
        Answer = "inactive_piece"

        ;

        Choice = 3
        ->
        Answer = "key_square"

        ;

        Choice = 4
        ->
        Answer = "opponent_weakness"

        ;

        Choice = 5
        ->
        Answer = "none"

        ;

        ask_position(Answer)
    ).
    

ask_attack_supported(Answer) :-

    nl,
    write('Is your attack against the weakness supported?'), nl,
    write('1. Yes'), nl,
    write('2. No'), nl,

    read(Choice),

    (
        Choice = 1
        ->
        Answer = "yes"

        ;

        Choice = 2
        ->
        Answer = "no"

        ;

        ask_attack_supported(Answer)
    ).


% ============================================================
% API ENTRY POINT
% ============================================================

api_main :-

    read_string(
        user_input,
        _,
        Input
    ),

    atom_json_dict(
        Input,
        Request,
        []
    ),

    get_dict(
        request,
        Request,
        RequestType
    ),

    (
        RequestType = "config"
        ->
        ui_knowledge:ui_data

        ;

        RequestType = "test"
        ->
        write('{"success":true}')

        ;

        RequestType = "analyze"
        ->
        api_analyze(Request)

        ;

        write('{"success":false,"error":"Unknown request."}')
    ).

% ============================================================
% API ANALYSIS
% ============================================================

api_analyze(Request) :-

    Answers = _{
        kingSafety: KingSafety,
        castlingRights: CastlingRights,
        development: Development,
        tactical: Tactical,
        pieceDefended: PieceDefended,
        material: Material,
        position: Position,
        attackSupported: AttackSupported
    },

    get_dict(
        kingSafety,
        Request,
        KingSafety
    ),

    get_optional_dict(
        Request,
        castlingRights,
        CastlingRights,
        "none"
    ),

    get_dict(
        development,
        Request,
        Development
    ),

    get_dict(
        tactical,
        Request,
        Tactical
    ),

    get_optional_dict(
        Request,
        pieceDefended,
        PieceDefended,
        "none"
    ),

    get_dict(
        material,
        Request,
        Material
    ),

    get_dict(
        position,
        Request,
        Position
    ),

    get_optional_dict(
        Request,
        attackSupported,
        AttackSupported,
        "none"
    ),

    analyze_answers(
        Answers,
        Recommendation
    ),

    ui_knowledge:recommendation_info(
        Recommendation,
        Info
    ),

    ui_knowledge:reasoning_info(
        Recommendation,
        Reasoning
    ),

    inference_engine:explanation_rules(
        Recommendation,
        RuleGroups
    ),

    flatten_rule_groups(
        RuleGroups,
        RuleNames
    ),

    json_write_dict(
        current_output,
        _{
            success: true,
            recommendation: Recommendation,
            info: Info,
            reasoning: Reasoning,
            rules: RuleNames,
            answers: Answers
        }
    ).


% ============================================================
% OPTIONAL DICTIONARY VALUE
% ============================================================

get_optional_dict(
    Dict,
    Key,
    Value,
    Default
) :-
    (
        get_dict(
            Key,
            Dict,
            Value
        )
        ->
        true
        ;
        Value = Default
    ).


% ============================================================
% FLATTEN RULE GROUPS
% ============================================================

flatten_rule_groups(
    [],
    []
).

flatten_rule_groups(
    [Group | Rest],
    Result
) :-

    flatten_rule_groups(
        Rest,
        RestResult
    ),

    append(
        Group,
        RestResult,
        Result
    ).