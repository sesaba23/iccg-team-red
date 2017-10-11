require 'rails_helper'
require 'byebug'


# testing strategy
# partitions:
# ===========
# ------
# basic queue
# ------
# not enough enqueued for game to start
# 3 incompatible* users queued
# 3 compatible users queued
# 4 users queued 3 of whom are compatible
# 3 compatible users queued but one declines
# 3 compatible users queued but one delcines, but then another compatible user joins
# ------
# correct roles assigned
# ------
# assigned roles consistent with known documents for each user
# assigned roles consistent with user preferences
# ===========
# * 3 users are considered compatible if the intersection of their selected document pools contains
#   at least one document for which a valid role assigment is possible. A role assignment is valid, if
#   the guesser is unfamiliar with the document and the assigment is compatible with user preferences.

describe SyncGamesManager do
  before(:each) do
    ## ONLY ONE DOCUMENT MAY BE MADE AVAILABLE HERE (otherwise some tests break)
    @document1 = FactoryGirl.create :document, kind: "text", title: "orcas",
                                    content: "Orcas are appex predators. They live in all oceans."
    # @document2 = FactoryGirl.create :document, kind: "text", title: "Muad'Dib",
    #                                 content: "Muad'Dib is a type of desert mouse, but it's also the chosen name of Paul Muad'Dib, the Lisan al Gaib."
    @user1 = FactoryGirl.create :user, id: 1, name: "user1",
                                email: "user1@email.com", password: "super_pw"
    @user2 = FactoryGirl.create :user, id: 2, name: "user2",
                                email: "user2@email.com", password: "super_pw"
    @user3 = FactoryGirl.create :user, id: 3, name: "user3",
                                email: "user3@email.com", password: "super_pw"
    @user4 = FactoryGirl.create :user, id: 4, name: "user4",
                                email: "user4@email.com", password: "super_pw"
    SyncGamesManager.first.destroy if SyncGamesManager.first
    SyncGamesManager.get
    @sgm = SyncGamesManager.get
  end
  describe "enqueues" do
    it "should cause a user to be reported as queued" do
      expect(@sgm.idle_users).to include(@user1)
      @sgm.enqueues @user1
      expect(@sgm.get_activity @user1).to eq(:queued)
      expect(@sgm.idle_users).not_to include(@user1)
    end
    it "should raise an exception if user not idle" do
      @sgm.enqueues @user1
      expect {@sgm.enqueues @user1}.to raise_error(IllegalStateTransitionError)
    end
  end
  describe "dequeues" do
    it "should cause a queued user to no longer be queued" do
      @sgm.enqueues @user1
      @sgm.dequeues @user1 
      expect(@sgm.idle_users).to include(@user1)
      expect(@sgm.get_activity @user1).to eq(:idle)
    end
    it "should raise StandardError if user not queued" do
      expect {@sgm.dequeues @user1}.to raise_error(IllegalStateTransitionError)
    end
  end
  describe "when 3 compatible users are queued" do
    before (:each) do
      @sgm.enqueues @user1
      @sgm.enqueues @user2
      @sgm.enqueues @user3
      @usrs = [@user1, @user2, @user3]
      @invite = @user1.invite ## ugh, rspec/FactoryGirl forgets about
                              ## user.invite if I don't don't do this...
    end
    it "their states should be :invited" do
      @usrs.
        map {|usr| @sgm.get_activity usr}.
        each {|activity| expect(activity).to eq(:invited)}
    end
    it "they should be able to see that a game is available for them" do
      @usrs.
        each {|usr| expect(@sgm.game_available_for? usr).to be_truthy}
    end
  end
  describe "when 3 compatible users are queued" do
    it "they should be able to tell the manager that they accept the game invite" do
      usrs = [@user1, @user2, @user3]
      usrs.each { |usr| @sgm.enqueues usr }
      User.all.each {|usr| @sgm.joins_game usr if @sgm.get_activity(usr) == :invited}
      usrs.each {|usr| expect(@sgm.playing_users).to include(usr)}
    end
  end
  describe "when 3 incompatible users are queued" do
    before do
      ## visit the available document
      @sgm.enqueues @user1
      @sgm.enqueues @user2
      @sgm.enqueues @user3
      @usrs = [@user1, @user2, @user3]
      User.all.each {|usr| @sgm.joins_game usr if @sgm.get_activity(usr) == :invited}
      User.all.each {|usr| @sgm.quits_game usr if @sgm.get_activity(usr) == :playing}

      ## queue again
      @sgm.enqueues @user1
      @sgm.enqueues @user2
      @sgm.enqueues @user3
    end
    it "their states should be reported as queued" do
      @usrs.each {|usr| expect(@sgm.queued_users).to include(usr)}
    end
    it "a game should not be available for them" do
      User.all.each {|usr| expect(@sgm.game_available_for? usr).to be_falsey}
    end
    it "they should not be able to join a game" do
      User.all.each {|usr| expect {@sgm.joins_game usr}.to raise_error(IllegalStateTransitionError)}
    end
    it "two of them should get a game invite if a forth (eligible) user joins" do
      @sgm.enqueues @user4
      expect(@sgm.game_available_for? @user4).to be_truthy
      expect(@usrs.map {|usr| @sgm.game_available_for? usr}.
              select {|available| available == true}.
              size).to eq(2)
    end
  end
  describe "when 3 compatible users are queued and two accept but one declines the invite" do
    before (:each) do
      @sgm.enqueues @user1
      @sgm.enqueues @user2
      @sgm.enqueues @user3
      @sgm.joins_game User.find(1)
      @sgm.joins_game User.find(2)
      @sgm.declines_game User.find(3)
    end
    it "the user who declined should become idle" do
      expect(@sgm.get_activity @user3).to eq(:idle)
    end
    it "the users who accepted should become queued" do
      expect(@sgm.get_activity @user1).to eq(:queued)
      expect(@sgm.get_activity @user2).to eq(:queued)
    end
    it "after another compatible user queues and all accept the invite, a game should become available" do
      @sgm.enqueues @user4
      @sgm.joins_game User.find(1)
      @sgm.joins_game User.find(2)
      @sgm.joins_game User.find(4)
      User.all.each {|usr| expect(@sgm.game_started_for usr).to be_truthy unless usr==@user3}
    end
  end
  describe "when 3 users are queued and one user wishes to play as guesser, and does not know the document" do
    before(:each) do
      @sgm.enqueues @user1
      @sgm.enqueues @user3, roles: [:guesser]
    end
    it "a game should start and the user should become guesser" do
      @sgm.enqueues @user2
      User.all.
        each {|usr| expect(@sgm.game_available_for? usr).to be_truthy unless usr == @user4}
      expect(@sgm.will_play_as User.find(3)).to eq(:guesser)
    end
    it "a second user also wishes to play as guesser a game should not start" do
      @sgm.enqueues @user2, roles: [:guesser]
      User.all.
        each {|usr| expect(@sgm.game_available_for? usr).to be_falsey}
    end
  end
  describe "when 4 compatible users queue as 2 judges, 1 reader and 1 guesser" do
    it "a game should start" do
      @sgm.enqueues @user1, roles: [:judge]
      @sgm.enqueues @user2, roles: [:guesser]
      @sgm.enqueues @user3, roles: [:judge]
      [@user1, @user2, @user3].
        each {|usr| expect(@sgm.game_available_for? usr).to be_falsey}
      @sgm.enqueues @user4, roles: [:reader]
      expect(@sgm.game_available_for? @user4).to be_truthy
      expect([@user1, @user2, @user3].
              map {|usr| @sgm.game_available_for? usr}.
              select {|available| available == true}.
              size).to eq(2)
    end
  end
end
