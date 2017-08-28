class JudgesController < ApplicationController

  def waiting_for_question
    judge = Judge.find_by_id(params[:id])
    if judge.question_available?
      redirect_to waiting_for_answers_game_judge_path and return
    end
    @whiteboard = judge.get_whiteboard_hashes
    @story = judge.get_document_text
  end

  def waiting_for_answers
    judge = Judge.find_by_id(params[:id])
    if judge.answers_available?
      redirect_to judging_game_judge_path and return
    end
    @whiteboard = judge.get_whiteboard_hashes
    @story = judge.get_document_text
    @question = judge.get_question
  end

  def judging
    judge = Judge.find_by_id(params[:id])
    unless judge.answers_available?
      redirect_to waiting_for_question_game_judge_path and return
    end
    if params[:judgement]
      judge.more_suspect_is(params[:judgement].to_sym)
      redirect_to waiting_for_question_game_judge_path and return
    end
    @whiteboard = judge.get_whiteboard_hashes
    @story = judge.get_document_text
    @question = judge.get_question
    answers = judge.get_answers
    @answer1 = answers[:answer1]
    @answer2 = answers[:answer2]
  end
end
