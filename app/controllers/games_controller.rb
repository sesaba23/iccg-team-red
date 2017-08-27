class GamesController < ApplicationController

  ### temporary, feel free to change
  def new
    @game = Game.create(document_id: params[:doc_id])
    @game.setup(1,2,3)
    redirect_to game_reader_path(id: 1, game_id: 1) if true
    redirect_to game_guesser_path(id: 1, game_id: 1) if false
  end
  
end
