class MultiplayerQueuesController < ApplicationController

  def enqueue
    MultiplayerQueue.create unless MultiplayerQueue.first
    @queue = MultiplayerQueue.first
    @user = session[:user_id]
    
    @queue.enqueue_player(@user)
    @queue.get_and_dequeue_game_players if @queue.enough_players_waiting
    
    redirect_to wait_multiplayer_queue_path and return
  end

  def wait
    @queue = MultiplayerQueue.first
    @user = session[:user_id]

    if @queue.selected_for_game(@user)
      redirect_to join_multiplayer_queue_path
    end
  end

  def join
    @queue = MultiplayerQueue.first
    @user = session[:user_id]
    @selected = [@queue.player1, @queue.player2, @queue.player3]

    @queue.if_not_already_done_start_game

    if @user == game.reader.user_id
      redirect_to waiting_for_question_game_reader_path(game.id, game.reader.id) and return
    elsif @user == game.guesser.user_id
      redirect_to waiting_for_question_game_guesser_path(game.id, game.guesser.id) and return
    elsif @user == game.judge.user_id
      redirect_to waiting_for_question_game_judge_path(game.id, game.judge.id) and return
    else
      raise StandardError
    end
    
  end
  
end
