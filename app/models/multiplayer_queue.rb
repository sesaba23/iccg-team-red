class MultiplayerQueue < ApplicationRecord
  has_many :queued_players

  # Only add player to queue if it is not in it
  def enqueue_player(user_id)
    if !self.queued_players.find_by_user_id(user_id)
      self.queued_players.push(QueuedPlayer.create(user_id: user_id)) 
      self.save
    end
  end
      

  def enough_players_waiting
    self.queued_players.size > 2
  end

  def get_and_dequeue_game_players
    raise StandardError unless self.queued_players.size > 2

    self.players_processed = 0
    
    usr_id1 = self.queued_players.first.user_id
    self.queued_players.destroy(QueuedPlayer.find_by_user_id(usr_id1))
    self.save
    usr_id2 = self.queued_players.first.user_id
    self.queued_players.destroy(QueuedPlayer.find_by_user_id(usr_id2))
    self.save
    usr_id3 = self.queued_players.first.user_id
    self.queued_players.destroy(QueuedPlayer.find_by_user_id(usr_id3))
    players = [usr_id1, usr_id2, usr_id3]
    self.player1 = usr_id1
    self.player2 = usr_id2
    self.player3 = usr_id3
    self.save
    return players
  end

  def deleted_selected_for_game_players
    self.player1 = ""
    self.player2 = ""
    self.player3 = ""
    self.save
  end

  def if_not_already_done_create_game
    return Game.find_by_id(self.game_id) if self.created
    doc_id = Document.all.map {|d| d.id}.sample
    game = Game.create(document_id: doc_id)
    game.setup(self.player1, self.player2, self.player3)
    self.created = true
    self.game_id = game.id
    self.save
    return game
  end

  def player_processed
    self.players_processed += 1
    self.save!
  end

  def game_processed
    self.players_processed == 3
  end

  def mark_game_started
    self.created = false
    self.players_processed = 0
    self.player1 = ""
    self.player2 = ""
    self.player3 = ""
    self.save
  end

  def selected_for_game(usr_id)
    usr_id == self.player1 or usr_id == self.player2 or usr_id == self.player3
  end

end    

