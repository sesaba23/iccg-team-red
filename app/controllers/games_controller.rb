class GamesController < ApplicationController
  
  def index
  end
  
  def show
    @game = Game.find(params[:id])
    redirect_to start_new_game_path if @game.state == 'game_over'
  end

  def game_over
    @game = Game.find(params[:id])
    @story = @game.document_content
    @scores = @game.get_scores
    @whiteboard = @game.get_whiteboard_hashes
  end

end
