
require 'byebug'

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
  serialize :games, Hash ## maps users to their active games
  has_many :invites ## represents an invitation to join a game
  has_many :requests ## represents a queued user
  
  @@states = [:idle, :queued, :invited, :playing] ## states users can have

  #################### CREATORS ####################

  # starts the manager.
  # makes sure that there is only one manager at all times.
  # returns: SyncGamesManager instance
  def SyncGamesManager.get
    SyncGamesManager.create if SyncGamesManager.all.empty?
    sgm = SyncGamesManager.first
    User.all.each { |user| sgm.user_state[user] = :idle if sgm.user_state[user].nil? }
    return sgm
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
    raise IllegalStateTransitionError unless user_state[user] == :idle
    roles = args[:roles]
    roles ||= [:reader, :guesser, :judge]
    documents = args[:documents]
    documents ||= Document.all
    
    add_request(user, roles, documents)
    
    if_possible_invite_and_remove_requests
  end

  # signal to the manager that a user has left the queue for syncronous games
  # must be queued in order to dequeue
  def dequeues (user)
    raise IllegalStateTransitionError unless user_state[user] == :queued
    # remove request and change user's state
    Request.destroy(user.request.id)
    user_state[user] = :idle
    self.save
  end

  # signal to the manager that a user has accepted the invitation to a synchronous game
  # game must be available for user, in order for them to join
  def joins_game (user)
    raise IllegalStateTransitionError unless user_state[user] == :invited
    invite = user.invite
    invite.accept user
    if invite.all_accepted?
      # create the game, change users' states to playing
      # and remove invite
      players = invite.users
      game = Game.setup(invite.document,
                        invite.reader_id, invite.guesser_id, invite.judge_id)
      players.each do |usr|
        user_state[usr] = :playing
        games[usr.id] = game.id
      end
      Invite.destroy(invite.id)
      self.save
    end
  end

  # signal to the manage that a user has declined the invitation to a synchronous game
  # game must be available for user, in order for them to decline
  def declines_game (user)
    raise IllegalStateTransitionError unless user_state[user] == :invited
    # set the declining user's state to idle and the other users' states to queued
    # and remove the invite
    users = user.invite.users
    user_state[user] = :idle
    users.each { |usr| user_state[usr] = :queued if usr != user }
    Invite.destroy(user.invite.id)
    self.save
  end

  # signal to the manager that a user has left a game
  # user must be playing in order to quit a game
  def quits_game (user)
    raise IllegalStateTransitionError unless user_state[user] == :playing
    # make sure the game is in it's game_over state and change the leaving
    # user's state to idle
    game = Game.find_by(id: games[user.id])
    game.force_end unless game.is_over
    user_state[user] = :idle
    games[user.id] = nil # forget that the user was playing this game
    self.save
  end

  #################### OBSERVERS ####################

  # determine if a game invite is available for user
  # param user: user object representing the user of interest
  # returns: boolean indidcating if an invite is available for user
  def game_available_for? (user)
    user_state[user] == :invited
  end

  # determine which role user is invited to play in
  # param user: user object representing the user of interest
  # raises: StandardError if user is not invited
  # returns: :reader, :guesser or :judge
  def will_play_as (user)
    raise StandardError unless user_state[user] == :invited
    invite = user.invite
    if invite.reader_id == user.id
      return :reader
    elsif invite.guesser_id == user.id
      return :guesser
    elsif invite.judge_id == user.id
      return :judge
    else
      raise StandardError # should never get here
    end
  end

  # determine if a game has started
  # returns: a boolean indiciating whether a game has started for this user
  def game_started_for (user)
    user_state[user] == :playing
  end

  # get a user's current activity, as far as the syncronous games manager is concerned.
  # param user: user object representing the user of interest
  # returns: one of the following: :idle, :queued, :invited, :playing
  def get_activity (user)
    user_state[user]
  end

  # returns: an enumerable containing all idle users
  def idle_users
    user_state.select { |user, state| state == :idle }.keys
  end

  # returns: an array of all users who are queued for a synchronous game
  def queued_users
    user_state.select { |user, state| state == :queued }.keys
  end

  # returns: an array of all users who are eligible to start a game
  def invited_users
    user_state.select { |user, state| state == :invited }.keys
  end

  # returns: an array of all users who are playing a synchronous game
  def playing_users
    user_state.select { |user, state| state == :playing }.keys
  end

  private

  def add_request (user, roles, documents)
    request = Request.create user: user,
                             reader: roles.include?(:reader),
                             guesser: roles.include?(:guesser),
                             judge: roles.include?(:judge),
                             sync_games_manager: self
    
    documents.each {|document| request.documents << document}
    user_state[user] = :queued
    self.save
  end

  def if_possible_invite_and_remove_requests
    match = match_for_game
    invite_and_remove_requests(match) if match
  end

  def invite_and_remove_requests(match)
    reader, guesser, judge, document = match
    users = [reader, guesser, judge].map {|r| r.user}
      
    invite = Invite.create sync_games_manager: SyncGamesManager.get,
                           reader_id: reader.user.id,
                           guesser_id: guesser.user.id,
                           judge_id: judge.user.id,
                           document: document
    
    users.each { |user| invite.users << user}
    self.invites << invite
      
    ## update user states and remove requests
    users.each do |user|
      Request.destroy(user.request.id)
      user_state[user] = :invited
    end
    self.save
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
        return reader, guesser, judge, judge.documents.sample
      end
    end
    return false
  end

  # param requests: an enumerable of requests
  # param request: the request which the other requests are suppoesed to be compatible with
  # returns: an enumerable containing requests that are compatible with request
  def compatible (requests, request)
    requests.
      select {|r| request.id != r.id}. # IMPORTANT to compare ids because requests can
                                       # be GuesserWrappers returned by Request#as_guesser
      select {|r| !((request.documents & r.documents).empty?)}
  end
end

class IllegalStateTransitionError < StandardError
end
