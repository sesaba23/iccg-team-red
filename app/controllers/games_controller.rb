class GamesController < ApplicationController
  def index
    @title = 'New Game'
    @url = waiting_players_path
  end
end
