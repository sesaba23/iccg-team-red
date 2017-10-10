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

class SyncGamesManager < ApplicationRecord

  # Rep Invariant:
  # Every existing user is in one of the @@states.
  # Every queued user has exactly one request. Only queued users have requests.
  # Every invited user is associated with exactly one invite. Only invited users are associated with invites.

  serialize :user_state, Hash ## maps users to their states
  has_many :invites ## represents an invitation to join a game
  has_many :requests ## represents a queued user
  
  @@states = [:idle, :queued, :invited, :playing] ## states users can have

  #################### CREATORS ####################

  # starts the manager.
  # makes sure that there is only one manager at all times.
  # returns: SyncGamesManager instance
  def SyncGamesManager.get
    SyncGamesManager.create if SyncGamesManager.all.empty?
    return SyncGamesManager.first
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
  def enqueues(user, **args)
    raise IllegalStateTransitionError unless user_state(user) == :idle
    roles = args[:roles]
    roles ||= [:reader, :guesser, :judge]
    documents = args[:documents]
    documents ||= Documents.all
    
    add_request(user, roles, documents)
    
    if_possible_invite_and_remove_requests
  end

  # signal to the manager that a user has left the queue for syncronous games
  # must be queued in order to dequeue
  def dequeues (user)
    raise IllegalStateTransitionError unless user_state[user] == :queued
    Request.destroy(user.request)
    user_state[user] = :idle
  end

  # signal to the manager that a user has accepted the invitation to a synchronous game
  # game must be available for user, in order for them to join
  def joins_game (user)
    raise IllegalStateTransitionError unless user_state[user] == :invited
    
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

  # determine if a game invite is available for for user
  # param user: user object representing the user of interest
  # returns: boolean indidcating if an invite is available for user
  def game_available_for? (user)
  end

  # determine which role user is invited to play in
  # param user: user object representing the user of interest
  # raises: StandardError if user is not invited
  # returns: :reader, :guesser or :judge
  def will_play_as (user)
  end

  # determine if a game has started
  # returns: a boolean indiciation whether a game has started for this user
  def game_started_for (user)
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

  private

  def add_request (user, roles, documents)
    request = Request.create user: user,
                             reader: roles.includes?(:reader),
                             guesser: roles.includes?(:guesser),
                             judge: roles.includes?(:judge),
                             sync_games_manager: self
    
    documents.each {|document| request.documents << document}
    user_state[user] = :queued
  end

  def if_possible_invite_and_remove_requests
    match = match_for_game
    invite_and_remove_requests(match) if match
  end

  def invite_and_remove_requests(match)
    reader, guesser, judge, document = match
    users = [reader, guesser, judge]
      
    invite = Invite.create sync_games_manager: SyncGamesManager.get,
                           reader_id: reader.id,
                           guesser_id: guesser.id,
                           judge_id: judge.id,
                           document: document
    users.each {|user| invites.users << user}
    self.invites << invite
      
    ## update user states and remove requests
    users.each do |user|
      Request.destroy(user.request)
      user_state[user] = :invited
    end
  end

  # tries to find 3 requests such that it's possible to assign each to a different role
  # and there is a document which the guesser is unfamiliar with
  # returns: 3 requests and an array of documents or false
  def match_for_game
    guessers = Request.where(guesser: true).
               # guesser.as_guesser behaves similarly to guesser but
               # uses the intersection of unknown and selected documents
               map {|guesser| guesser.as_guesser}
    judges = Request.where(judge: true)
    readers = Request.where(reader: true)

    guessers.each do |guesser|
      guesser_judges = compatible judges, guesser
      compatible_readers = compatible readers, guesser
      next if guesser_judges.empty? || compatible_readers.empty?

      compatible_readers.each do |reader|
        compatible_judges = compatible guesser_judges, reader
        next if compatible_judges.empty?
        judge = compatible_judges.sample
        return reader, guesser, judge, judge.documents
      end
    end
    return false
  end

  # param requests: an enumerable of requests
  # param request: the request which the other requests are suppoesed to be compatible with
  # returns: an enumerable containing requests that are compatible with request
  def compatible (requests, request)
    requests.select {|r| !((request.documents & r.documents).empty?)}
  end
end
