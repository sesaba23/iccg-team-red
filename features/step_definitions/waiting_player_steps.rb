  Given /^the user "(.*)" is waiting for players$/ do |username|
  user = User.find_by(name: username)
  WaitingPlayer.create(user_id: user.id, active: true)
end

Given /^the user "(.*)" exist on a game$/ do |username|
  user = User.find_by(name: username)
  WaitingPlayer.create(user_id: user.id, active: true)
  user1 = User.create(name: "User1", email: "user1@test.com", password: "foobar", password_confirmation: "foobar", admin: false)
  WaitingPlayer.create(user_id: user1.id, active: true)
  user2 = User.create(name: "User2", email: "user2@test.com", password: "foobar", password_confirmation: "foobar", admin: false)
  WaitingPlayer.create(user_id: user2.id, active: true)
  players = []
  players.push(user)
  players.push(user1)
  players.push(user2)
  document = Document.create(doc_type: "text", text: "Some Orcas hunt Great Whites. They knock them out, suffacte them, and eat their livers.")
  game = Game.create(document_id: document.id)
  players.shuffle!
  game.setup(players[0], players[1], players[2])
end