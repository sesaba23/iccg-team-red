class GamesController < ApplicationController
  def index
  end
  
  def show
    @game = Game.find(params[:id])
    redirect_to start_new_game_path if @game.state == 'game_over'
  end
end
