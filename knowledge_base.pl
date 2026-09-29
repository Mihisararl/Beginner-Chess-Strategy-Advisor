:- module(knowledge_base, [
    king_safe/1,
    king_castled/1,
    castling_rights/1,
    center_status/1,
    own_development/1,
    opponent_development/1,
    own_piece_attacked/1,
    piece_defended/1,
    immediate_threat/1,
    material_status/1,
    tactical_opportunity/1,
    opponent_attacking_king/1,
    open_lines_to_king/1,
    pawn_storm_near_king/1,
    sacrifice_against_king/1,
    own_minor_pieces_developed/1,
    opponent_minor_pieces_developed/1,
    worst_piece_inactive/1,
    pawn_structure_weak/1,
    key_square_available/1,
    rook_connected/1,
    target_available/1,
    counterattack_risk/1,
    position_has_weaknesses/1,
    opponent_has_more_weaknesses/1,
    attack_supported/1,
    opening_phase/1,
    exchange_favorable/1,
    opponent_best_piece_can_be_traded/1,
    future_plan_available/1,
    clear_facts/0,
    all_facts/1,

    r01_king_danger/0,
    r02_king_danger/0,
    r03_king_danger/0,
    r04_king_danger/0,
    r05_king_danger/0,
    r06_prioritize_king_safety/0,
    r07_castling_possible/0,
    r08_recommend_castling/0,
    r09_recommend_castling/0,
    r10_development_disadvantage/0,
    r11_recommend_development/0,
    r12_defend_immediately/0,
    r13_piece_in_danger/0,
    r14_protect_piece/0,
    r15_look_for_check/0,
    r16_consider_fork/0,
    r17_consider_pin/0,
    r18_prioritize_attack/0,
    r19_avoid_premature_attack/0,
    r20_prioritize_defense/0,
    r21_prioritize_attack/0,
    r22_simplify_when_ahead/0,
    r23_avoid_exchanges_when_behind/0,
    r24_trade_opponent_best_piece/0,
    r25_consider_favorable_exchange/0,
    r26_improve_worst_piece/0,
    r27_improve_pawn_structure/0,
    r28_control_key_square/0,
    r29_positional_improvement/0,
    r30_make_useful_move/0
]).


:- dynamic [
    king_safe/1,
    king_castled/1,
    castling_rights/1,
    center_status/1,
    own_development/1,
    opponent_development/1,
    own_piece_attacked/1,
    piece_defended/1,
    immediate_threat/1,
    material_status/1,
    tactical_opportunity/1,
    opponent_attacking_king/1,
    open_lines_to_king/1,
    pawn_storm_near_king/1,
    sacrifice_against_king/1,
    own_minor_pieces_developed/1,
    opponent_minor_pieces_developed/1,
    worst_piece_inactive/1,
    pawn_structure_weak/1,
    key_square_available/1,
    rook_connected/1,
    target_available/1,
    counterattack_risk/1,
    position_has_weaknesses/1,
    opponent_has_more_weaknesses/1,
    attack_supported/1,
    opening_phase/1,
    exchange_favorable/1,
    opponent_best_piece_can_be_traded/1,
    future_plan_available/1
].


% ============================================================
% EXPERT RULES
% ============================================================

% R01
r01_king_danger :-
    king_castled(no),
    center_status(open).

% R02
r02_king_danger :-
    king_castled(no),
    open_lines_to_king(yes).

% R03
r03_king_danger :-
    opponent_attacking_king(yes).

% R04
r04_king_danger :-
    pawn_storm_near_king(yes).

% R05
r05_king_danger :-
    sacrifice_against_king(yes).

% R06
r06_prioritize_king_safety :-
    r01_king_danger.

r06_prioritize_king_safety :-
    r02_king_danger.

r06_prioritize_king_safety :-
    r03_king_danger.

r06_prioritize_king_safety :-
    r04_king_danger.

r06_prioritize_king_safety :-
    r05_king_danger.


% R07
r07_castling_possible :-
    king_castled(no),
    castling_rights(yes).


% R08
r08_recommend_castling :-
    r07_castling_possible,
    king_safe(yes).


% R09
r09_recommend_castling :-
    r07_castling_possible,
    r06_prioritize_king_safety.


% R10
r10_development_disadvantage :-
    own_development(low),
    opponent_development(high).


% R11
r11_recommend_development :-
    r10_development_disadvantage.


% R12
r12_defend_immediately :-
    immediate_threat(yes).


% R13
r13_piece_in_danger :-
    own_piece_attacked(yes),
    piece_defended(no).


% R14
r14_protect_piece :-
    r13_piece_in_danger.


% R15
r15_look_for_check :-
    tactical_opportunity(check).


% R16
r16_consider_fork :-
    tactical_opportunity(fork).


% R17
r17_consider_pin :-
    tactical_opportunity(pin).


% R18
r18_prioritize_attack :-
    attack_supported(yes),
    target_available(yes),
    king_safe(yes).


% R19
r19_avoid_premature_attack :-
    attack_supported(no).


% R20
r20_prioritize_defense :-
    position_has_weaknesses(yes).


% R21
r21_prioritize_attack :-
    opponent_has_more_weaknesses(yes),
    king_safe(yes).


% R22
r22_simplify_when_ahead :-
    material_status(ahead).


% R23
r23_avoid_exchanges_when_behind :-
    material_status(behind).


% R24
r24_trade_opponent_best_piece :-
    opponent_best_piece_can_be_traded(yes).


% R25
r25_consider_favorable_exchange :-
    exchange_favorable(yes).


% R26
r26_improve_worst_piece :-
    worst_piece_inactive(yes),
    immediate_threat(no).


% R27
r27_improve_pawn_structure :-
    pawn_structure_weak(yes),
    immediate_threat(no).


% R28
r28_control_key_square :-
    key_square_available(yes),
    immediate_threat(no).


% R29
r29_positional_improvement :-
    tactical_opportunity(none),
    immediate_threat(no),
    future_plan_available(yes).


% R30
r30_make_useful_move :-
    tactical_opportunity(none),
    immediate_threat(no),
    future_plan_available(no).

% ============================================================
% CLEAR ALL DYNAMIC FACTS
% ============================================================

clear_facts :-
    retractall(king_safe(_)),
    retractall(king_castled(_)),
    retractall(castling_rights(_)),
    retractall(center_status(_)),
    retractall(own_development(_)),
    retractall(opponent_development(_)),
    retractall(own_piece_attacked(_)),
    retractall(piece_defended(_)),
    retractall(immediate_threat(_)),
    retractall(material_status(_)),
    retractall(tactical_opportunity(_)),
    retractall(opponent_attacking_king(_)),
    retractall(open_lines_to_king(_)),
    retractall(pawn_storm_near_king(_)),
    retractall(sacrifice_against_king(_)),
    retractall(own_minor_pieces_developed(_)),
    retractall(opponent_minor_pieces_developed(_)),
    retractall(worst_piece_inactive(_)),
    retractall(pawn_structure_weak(_)),
    retractall(key_square_available(_)),
    retractall(rook_connected(_)),
    retractall(target_available(_)),
    retractall(counterattack_risk(_)),
    retractall(position_has_weaknesses(_)),
    retractall(opponent_has_more_weaknesses(_)),
    retractall(attack_supported(_)),
    retractall(opening_phase(_)),
    retractall(exchange_favorable(_)),
    retractall(opponent_best_piece_can_be_traded(_)),
    retractall(future_plan_available(_)).


% ============================================================
% RETURN ALL CURRENT FACTS
% ============================================================

all_facts(Facts) :-
    findall(
        Fact,
        (
            fact_name(Name),
            Goal =.. [Name, Value],
            call(Goal),
            Fact = Goal
        ),
        Facts
    ).


% ============================================================
% FACT PREDICATE NAMES
% ============================================================

fact_name(king_safe).
fact_name(king_castled).
fact_name(castling_rights).
fact_name(center_status).
fact_name(own_development).
fact_name(opponent_development).
fact_name(own_piece_attacked).
fact_name(piece_defended).
fact_name(immediate_threat).
fact_name(material_status).
fact_name(tactical_opportunity).
fact_name(opponent_attacking_king).
fact_name(open_lines_to_king).
fact_name(pawn_storm_near_king).
fact_name(sacrifice_against_king).
fact_name(own_minor_pieces_developed).
fact_name(opponent_minor_pieces_developed).
fact_name(worst_piece_inactive).
fact_name(pawn_structure_weak).
fact_name(key_square_available).
fact_name(rook_connected).
fact_name(target_available).
fact_name(counterattack_risk).
fact_name(position_has_weaknesses).
fact_name(opponent_has_more_weaknesses).
fact_name(attack_supported).
fact_name(opening_phase).
fact_name(exchange_favorable).
fact_name(opponent_best_piece_can_be_traded).
fact_name(future_plan_available).