Given /^the user "(.*)" is waiting for players$/ do |username|
  user = User.find_by(name: username)
  WaitingPlayer.create(user_id: user.id, active: true)
end

Given /^the user "(.*)" exist on a game$/ do |username|
  user = User.find_by(name: username)
  document = Document.create(doc_type: "text", text: "Some Orcas hunt Great Whites. They knock them out, suffacte them, and eat their livers.")
  game = Game.create(document_id: document.id)
  Reader.create(user_id: user.id, game_id: game.id)
  visit('/start-new-game')
end