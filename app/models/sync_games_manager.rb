class SyncGamesManager < ApplicationRecord

  serialize :idle, Array

  ## Purpose:
  ## The purpose of this model is to coordinate the other models that are involved in playing
  ## synchronous games.
  ## Specficially, this model is responsible for starting and ending games, and monitoring user
  ## activity insofar as that activity indiciates that documents are viewed, and games are
  ## started or abandoned.
  ##
  ## * Every user can play only one synchronous game at a time.
  ## * When a game starts, the user's known document lists must be updated to include the
  ##   document of the new game.
  ## * When players leave games, the games must end up in their game_over state.
  ## * Guessers should not be familiar with the documents of their games from previous games.

  #################### CREATORS ####################

  # starts the manager.
  # makes sure that there is only one manager at all times.
  def SyncGamesManager.init
  end

  #################### MUTATORS ####################

  ## messages to the manager

  # param user: user object representing the user of interest
  
  # signal to the manager that a user has logged in
  def comes_online (user)
  end

  # signal to the manager that a user has gone offline
  # (signed out, timed out or quit the browser window)
  def goes_offline (user)
  end

  # signal to the manager that a user has queued for synchronous games
  def enqueues (user)
  end

  # signal to the manager that a user has left the queue for syncronous games
  def dequeues (user)
  end

  # signal to the manager that a user has accepted the invitation to a synchronous game
  def joins_game (user)
  end

  # signal to the manager that a user has left a game
  def quits_game (user)
  end

  #################### OBSERVERS ####################

  ## concerning users

  # determine if a game can start for user
  # param user: user object representing the user of interest
  # returns: boolean indidcating if a game is available for user
  def game_available_for? (user)
  end

  # get a user's current activity, as far as the syncronous manager is concerned.
  # param user: user object representing the user of interest
  # returns: one of the following: :offline, :idle, :queued, :playing
  def get_activity (user)
  end

  # returns: an array of all idle users
  def idle_users
  end

  # returns: an array of all users who are playing a synchronous game
  def playing_users
  end

  # returns: an array of all users who are queued for a synchronous game
  def queued_users
  end

  ## concerning games

  # returns: an array of all active synchrnonous games
  def get_active_games
  end

  # returns: an array of all previously concluded games
  def get_finished_games
  end
end
