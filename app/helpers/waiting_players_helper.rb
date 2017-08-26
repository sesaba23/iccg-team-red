module WaitingPlayersHelper
  def game_for_current_user
    reader = Reader.where(user_id: current_user).joins(:game).where.not(games: {state: 'game_over'}).limit(1)
    guesser = Guesser.where(user_id: current_user).joins(:game).where.not(games: {state: 'game_over'}).limit(1)
    judge = Judge.where(user_id: current_user).joins(:game).where.not(games: {state: 'game_over'}).limit(1)
    game = reader[0] || guesser[0] || judge[0]
    @game = Game.find(game.game_id) unless game.nil?
  end
  
  def current_user_waiting?
    user = WaitingPlayer.find_by(user_id: current_user, active: true)
    return false if user.nil?
    user.user_id == current_user
  end
  
  def game_setup
    queue = WaitingPlayer.where(active: true).where.not(user_id: current_user).limit(2)
    if queue.count >= 2
      players = [current_user]
      queue.each {|x| players.push(x.user_id)}
      players.shuffle!
      players.each {|x| WaitingPlayer.find_by(user_id: x).update_attributes(active: false) }
      document = get_free_document
      return nil if document.empty?
      @game = set_new_game(document.first, players)
    else
      return nil
    end
  end
  
  def get_free_document
    document = Document.left_outer_joins(:games).where(games: {document_id: nil}).limit(1)
  end
  
  def set_new_game(document, players)
    @game = Game.create(document_id: document)
    @game.setup(players[0], players[1], players[2]) if @game
    return @game
  end
end
