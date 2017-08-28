class GuessersController < ApplicationController

  def waiting_for_question
    guesser = Guesser.find_by_id(params[:id])
    if guesser.is_questioner?
      redirect_to ask_game_guesser_path and return
    elsif guesser.question_available?
      redirect_to answer_game_guesser_path and return
    else
      @whiteboard = guesser.get_whiteboard_hashes
      render "waiting_for_question" and return
    end
  end
  
  def ask
    guesser = Guesser.find_by_id(params[:id])
    unless guesser.is_questioner?
      redirect_to waiting_for_question_game_guesser_path and return
    end
    if guesser.question_available?
      redirect_to answer_game_guesser_path and return
    end
    @whiteboard = guesser.get_whiteboard_hashes
    @ask_path = ask_game_guesser_path
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
    guesser = Guesser.find_by_id(params[:id])
    if guesser.get_guessers_answer
      redirect_to review_game_guesser_path and return
    end
    @whiteboard = guesser.get_whiteboard_hashes
    @question = Guesser.find_by_id(params[:id]).get_question
    if params[:answer]
      begin
        guesser.submit_answer(params[:answer])
        redirect_to review_game_guesser_path and return
      rescue NoContentError
        flash[:alert] = "You have to answer something!"
        redirect_to answer_game_reader_path and return
      end
    else
      @answer_path = answer_game_guesser_path
      render 'answer' and return
    end
  end

  def review
    guesser = Guesser.find_by_id(params[:id])
    unless guesser.get_guessers_answer
      redirect_to waiting_for_question_game_guesser_path and return
    end
    if guesser.new_round? and guesser.is_questioner?
      redirect_to ask_game_guesser_path and return
    elsif guesser.new_round? and !guesser.is_questioner?
      redirect_to waiting_for_question_game_guesser_path and return
    else
      @whiteboard = guesser.get_whiteboard_hashes
      @question = guesser.get_question
      @readers_answer = guesser.get_readers_answer
      @guessers_answer = guesser.get_guessers_answer
      render 'review' and return
    end
  end 
end
