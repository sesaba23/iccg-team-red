class SyncGamesManager < ApplicationRecord

  serialize :idle, Array
  serialize :queued, Array
  serialize :invited, Array
  serialize :playing, Array
  serialize :active_games, Array
  serialize :finished_games, Array

  ## Purpose:
  ## The purpose of this model is to coordinate the other models that are involved in playing
  ## synchronous games.
  ## Specficially, this model is responsible for starting and ending games, updating seen documents
  ## and monitoring user activity insofar as that activity indiciates that documents are interacted with,
  ## the queue is joined or left and games are started or abandoned.
  ##
  ## * Every user can play only one synchronous game at a time.
  ## * When a game starts, the user's known-documents lists must be updated to include the
  ##   document of the new game.
  ## * When players leave games, the games must end up in their game_over states.
  ## * Guessers should not be familiar with the documents of their games from previous games.
  ## * Games should start as soon as three compatible players have joined the queue.
  ##   (At least one of them must be unfamiliar with the document.)

  #################### CREATORS ####################

  # starts the manager.
  # makes sure that there is only one manager at all times.
  def SyncGamesManager.init
  end

  #################### MUTATORS ####################

  ## messages to the manager

  # all methods:
  # param user: user object representing the user of interest

  # signal to the manager that a user has queued for synchronous games
  # optional param roles: an array containing a non-empty subset of {:reader, :guesser, :judge},
  #                indicating which roles the user is willing to play in the game.
  # optional param documents: an array of documents the user is willing to play with
  # must be idle to be able to enqueue
  def enqueues(user, *args)
  end

  # signal to the manager that a user has left the queue for syncronous games
  # must be queued in order to dequeue
  def dequeues (user)
  end

  # signal to the manager that a user has accepted the invitation to a synchronous game
  # game must be available for user, in order for them to join
  def joins_game (user)
  end

  # signal to the manage that a user has declined the invitation to a synchronous game
  # game must be available for user, in order for them to decline
  def declines_game (user)
  end

  # signal to the manager that a user has left a game
  # user must be playing in order to quit a game
  def quits_game (user)
  end

  #################### OBSERVERS ####################

  ## concerning users

  # determine if a game can start for user
  # param user: user object representing the user of interest
  # returns: boolean indidcating if a game is available for user
  def game_available_for? (user)
  end

  # determine which role user is invited to play in
  # param user: user object representing the user of interest
  # raises: StandardError if user is not invited
  # returns: :reader, :guesser or :judge
  def will_play_as (user)
  end

  # get a user's current activity, as far as the syncronous manager is concerned.
  # param user: user object representing the user of interest
  # returns: one of the following: :idle, :queued, :playing
  def get_activity (user)
  end

  # returns: an array of all idle users
  def idle_users
  end

  # returns: an array of all users who are eligible to start a game
  def invited_users
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
