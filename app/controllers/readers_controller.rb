class ReadersController < ApplicationController

  def waiting_for_question
    reader = Reader.find_by_id(params[:id])
    if reader.question_available?
      redirect_to answer_game_guesser_path and return
    else
      @whiteboard = reader.get_whiteboard_hashes
      render "waiting_for_question" and return
    end
  end
  
  def ask
    reader = Reader.find_by_id(params[:id])
    if params[:question]
      begin
        reader.submit_question(params[:question])
      rescue NoContentError
        flash[:alert] = "You need to ask something."
        redirect_to ask_game_reader_path and return
      end
      redirect_to answer_game_reader_path and return
    end
    @story = reader.get_document_text
    @whiteboard = reader.get_whiteboard_hashes
    render 'ask'
  end

  def answer
    @question = Reader.find_by_id(params[:id]).get_question
  end

  def review
    reader = Reader.find_by_index(params[:id])
    if reader.new_round? and reader.is_questioner?
      redirect_to ask_game_reader_path and return
    elsif reader.new_round? and reader.question_available?
      redirect_to _game_reader_path and return
    else
      redirect_to wait_for_question_game_reader_path and return
    end
  end
  
end
