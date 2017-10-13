class RgController < ApplicationController
  
  def get_round_data
    question = if @player.question_available? then @player.get_question else "" end
    round_data = {is_questioner: @player.is_questioner?,
                  new_round: @player.new_round?,
                  question_available: @player.question_available?,
                  answers_available: @player.answers_available?,
                  question: question,
                  reader_answer: @player.get_readers_answer,
                  guesser_answer: @player.get_guessers_answer,
                  scores: @player.get_scores,
                  whiteboard: @player.get_whiteboard_hashes,
                  game_over: @player.is_game_over}
    render json: round_data
  end

  def submit_question
    begin
      @player.submit_question(params[:question])
    rescue NoContentError
      flash[:alert] = "You have to ask something!"
    end
  end

  def submit_answer
    begin
      @player.submit_answer(params[:answer])
    rescue
      flash[:alert] = "You have to answer something!"
    end
  end
  
end
