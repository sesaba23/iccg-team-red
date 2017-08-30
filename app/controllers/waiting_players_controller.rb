include WaitingPlayersHelper

class WaitingPlayersController < ApplicationController
  before_action :logged_in_user, only: [:index, :waiting]
  
  def index
    @game = game_for_current_user
    if @game 
      redirect_to_play_game
    else
      redirect_to waiting_players_path if current_user_waiting?
    end
    @title = 'New Game'
    @url = waiting_players_path
  end
  
  # Waits till three players are available for playing game
  def waiting
    if !current_user_waiting?
      WaitingPlayer.create(user_id: current_user.id, active: true)
    end
    @game = game_setup
    
    if !@game.nil?
      redirect_to_play_game
    end
  end
  
  def redirect_to_play_game
    if session[:next_player].nil?
      session[:next_player] = 'reader'
    end

    if session[:next_player] == 'reader'
      redirect_to  waiting_for_question_game_reader_path(1, 1)
      session[:next_player] = 'guesser'
      return
    elsif session[:next_player] == 'guesser'
      redirect_to  waiting_for_question_game_guesser_path(1, 1)
      session[:next_player] = 'judge'
      return
    elsif
      redirect_to  waiting_for_question_game_judge_path(1, 1)
      session[:next_player] = 'reader'
    end
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
