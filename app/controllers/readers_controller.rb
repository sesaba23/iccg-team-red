class ReadersController < ApplicationController
  
  def waiting_for_question
    reader = Reader.find_by_id(params[:id])
    @story = reader.get_document_text
    if reader.is_questioner?
      redirect_to ask_game_reader_path and return
    elsif reader.question_available?
      redirect_to answer_game_reader_path and return
    else
      @whiteboard = reader.get_whiteboard_hashes
      render "waiting_for_question" and return
    end
  end
  
  def ask
    reader = Reader.find_by_id(params[:id])
    unless reader.is_questioner?
      redirect_to waiting_for_question_game_reader_path and return
    end
    if reader.question_available?
      redirect_to answer_game_reader_path and return
    end
    @story = reader.get_document_text
    @whiteboard = reader.get_whiteboard_hashes
    @ask_path = ask_game_reader_path
    if params[:question]
      begin
        reader.submit_question(params[:question])
        redirect_to answer_game_reader_path and return
      rescue NoContentError
        flash[:alert] = "You have to ask something!"
        redirect_to ask_game_reader_path and return
      end
    else
      render 'ask' and return
    end
  end

  def answer
    ### should only get to answer view if
    ### answer not yet available 
    reader = Reader.find_by_id(params[:id])
    if reader.get_readers_answer
      redirect_to review_game_reader_path and return
    end
    @story = reader.get_document_text
    @whiteboard = reader.get_whiteboard_hashes
    @question = Reader.find_by_id(params[:id]).get_question
    if params[:answer]
      begin
        reader.submit_answer(params[:answer])
        redirect_to review_game_reader_path and return
      rescue NoContentError
        flash[:alert] = "You have to answer something!"
        redirect_to answer_game_reader_path and return
      end
    else
      @answer_path = answer_game_reader_path
      render 'answer' and return
    end
  end

  def review
    reader = Reader.find_by_id(params[:id])
    unless reader.get_readers_answer
      redirect_to waiting_for_question_game_reader_path and return
    end
    if reader.new_round? and reader.is_questioner?
      redirect_to ask_game_reader_path and return
    elsif reader.new_round? and !reader.is_questioner?
      redirect_to waiting_for_question_game_reader_path and return
    elsif reader.is_game_over
      redirect_to game_over_game_path(reader.game) and return
    else
      @story = reader.get_document_text
      @whiteboard = reader.get_whiteboard_hashes
      @question = reader.get_question
      @readers_answer = reader.get_readers_answer
      @guessers_answer = reader.get_guessers_answer
      render 'review' and return
    end
  end
  
end
