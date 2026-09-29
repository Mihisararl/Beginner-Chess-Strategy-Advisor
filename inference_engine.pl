:- module(inference_engine, [
    recommend/1,
    explanation_rules/2
]).

:- use_module(knowledge_base).


% ============================================================
% INFERENCE ENGINE
% Backward chaining is used.
%
% Rules are checked according to expert priority.
% ============================================================

recommend(king_safety) :-
    knowledge_base:r06_prioritize_king_safety,
    !.

recommend(defend_immediately) :-
    knowledge_base:r12_defend_immediately,
    !.

recommend(protect_piece) :-
    knowledge_base:r14_protect_piece,
    !.

recommend(check) :-
    knowledge_base:r15_look_for_check,
    !.

recommend(fork) :-
    knowledge_base:r16_consider_fork,
    !.

recommend(pin) :-
    knowledge_base:r17_consider_pin,
    !.

recommend(castle) :-
    knowledge_base:r08_recommend_castling,
    !.

recommend(develop_piece) :-
    knowledge_base:r11_recommend_development,
    !.

recommend(attack) :-
    knowledge_base:r18_prioritize_attack,
    !.

recommend(simplify) :-
    knowledge_base:r22_simplify_when_ahead,
    !.

recommend(improve_worst_piece) :-
    knowledge_base:r26_improve_worst_piece,
    !.

recommend(improve_pawn_structure) :-
    knowledge_base:r27_improve_pawn_structure,
    !.

recommend(control_key_square) :-
    knowledge_base:r28_control_key_square,
    !.

recommend(improve_position) :-
    knowledge_base:r29_positional_improvement,
    !.

recommend(make_useful_move) :-
    knowledge_base:r30_make_useful_move,
    !.

recommend(no_recommendation).


% ============================================================
% RULE TRACE
% ============================================================

explanation_rules(king_safety, Rules) :-
    findall(
        Rule,
        (
            member(
                Rule,
                [
                    r01_king_danger,
                    r02_king_danger,
                    r03_king_danger,
                    r04_king_danger,
                    r05_king_danger
                ]
            ),
            call(knowledge_base:Rule)
        ),
        Triggered
    ),
    Rules = [
        Triggered,
        [r06_prioritize_king_safety]
    ].

explanation_rules(defend_immediately, [
    [r12_defend_immediately]
]) :-
    knowledge_base:r12_defend_immediately.

explanation_rules(protect_piece, [
    [r13_piece_in_danger],
    [r14_protect_piece]
]) :-
    knowledge_base:r14_protect_piece.

explanation_rules(check, [
    [r15_look_for_check]
]) :-
    knowledge_base:r15_look_for_check.

explanation_rules(fork, [
    [r16_consider_fork]
]) :-
    knowledge_base:r16_consider_fork.

explanation_rules(pin, [
    [r17_consider_pin]
]) :-
    knowledge_base:r17_consider_pin.

explanation_rules(castle, [
    [r07_castling_possible],
    [r08_recommend_castling]
]) :-
    knowledge_base:r08_recommend_castling.

explanation_rules(develop_piece, [
    [r10_development_disadvantage],
    [r11_recommend_development]
]) :-
    knowledge_base:r11_recommend_development.

explanation_rules(attack, [
    [r18_prioritize_attack]
]) :-
    knowledge_base:r18_prioritize_attack.

explanation_rules(simplify, [
    [r22_simplify_when_ahead]
]) :-
    knowledge_base:r22_simplify_when_ahead.

explanation_rules(improve_worst_piece, [
    [r26_improve_worst_piece]
]) :-
    knowledge_base:r26_improve_worst_piece.

explanation_rules(improve_pawn_structure, [
    [r27_improve_pawn_structure]
]) :-
    knowledge_base:r27_improve_pawn_structure.

explanation_rules(control_key_square, [
    [r28_control_key_square]
]) :-
    knowledge_base:r28_control_key_square.

explanation_rules(improve_position, [
    [r29_positional_improvement]
]) :-
    knowledge_base:r29_positional_improvement.

explanation_rules(make_useful_move, [
    [r30_make_useful_move]
]) :-
    knowledge_base:r30_make_useful_move.

explanation_rules(no_recommendation, []).