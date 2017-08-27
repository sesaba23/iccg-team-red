class GuessersController < ApplicationController

  def waiting_for_question
    guesser = Guesser.find_by_id(params[:id])
    if guesser.question_available?
      redirect_to answer_game_guesser_path and return
    else
      @whiteboard = guesser.get_whiteboard_hashes
      render "waiting_for_question" and return
    end
  end
  
  def ask
    guesser = Guesser.find_by_id(params[:id])
    if params[:question]
      begin
        guesser.submit_question(params[:question])
      rescue NoContentError
        flash[:alert] = "You need to ask something."
        redirect_to ask_game_guesser_path and return
      end
      redirect_to answer_game_guesser_path and return
    end
  end

  def answer
  end

  def review
    guesser = Guesser.find_by_index(params[:id])
    if guesser.new_round? and guesser.is_questioner?
      redirect_to ask_game_guesser_path and return
    elsif guesser.new_round? and guesser.question_available?
      redirect_to _game_guesser_path and return
    else
      redirect_to wait_for_question_game_guesser_path and return
    end
  end 
end
