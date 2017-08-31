class MultiplayerQueue < ApplicationRecord
  has_many :queued_players

  def enqueue_player(user_id)
    self.queued_players.push(QueuedPlayer.create(user_id: user_id)) unless
      self.queued_players.find_by_user_id(user_id)
  end

  def enough_players_waiting
    self.queued_players.size > 2
  end

  def get_and_dequeue_game_players
    raise StandardError unless self.queued_players.size > 2
    usr_id1 = self.queued_players.first.user_id
    self.queued_players.destroy(QueuedPlayer.find_by_user_id(usr_id1))
    usr_id2 = self.queued_players.first.user_id
    self.queued_players.destroy(QueuedPlayer.find_by_user_id(usr_id2))
    usr_id3 = self.queued_players.first.user_id
    self.queued_players.destroy(QueuedPlayer.find_by_user_id(usr_id3))
    players = [usr_id1, usr_id2, usr_id3]
    self.player1 = usr_id1
    self.player2 = usr_id2
    self.player3 = usr_id3
    self.save
    return players
  end

  def selected_for_game(usr_id)
    usr_id == self.player1 or usr_id == self.player2 or usr_id == self.player3
  end
    
  
end
