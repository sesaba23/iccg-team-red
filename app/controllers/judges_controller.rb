class JudgesController < ApplicationController

  before_action :get_judge
  
  def get_round_data
    question = if @player.question_available? then @player.get_question else "" end
    answers = if @player.answers_available? then @player.get_answers else nil end
    round_data = {new_round: @player.new_round?,
                  question_available: @player.question_available?,
                  question: question,
                  answers_available: @player.answers_available?,
                  answers: answers,
                  scores: @player.get_scores,
                  whiteboard: @player.get_whiteboard_hashes}
    render json: round_data
  end
  
  def get_document_data
    document = {type: @player.get_document_type,
                title: @player.get_document_name,
                body: @player.get_document_text}
    render json: document
  end

  def select_better_answer
    other = {answer1: :answer2, answer2: :answer1}
    @player.more_suspect_is(other[params[:better_answer].to_sym])
  end

  private

  def get_judge
    @player = Judge.find(params[:id])
  end
  
end
