include WaitingPlayersHelper

class WaitingPlayersController < ApplicationController
  before_action :logged_in_user, only: [:index, :waiting]
  
  def index
    @game = game_for_current_user
    redirect_to @game if @game
    redirect_to waiting_players_path if current_user_waiting?
    @title = 'New Game'
    @url = waiting_players_path
  end
  
  # Waits till three players are available for playing game
  def waiting
    if !current_user_waiting?
      WaitingPlayer.create(user_id: current_user, active: true)
    end
    @game = game_setup
    redirect_to @game unless @game.nil?
  end
  
  private
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in"
        redirect_to login_url
      end
    end
end
