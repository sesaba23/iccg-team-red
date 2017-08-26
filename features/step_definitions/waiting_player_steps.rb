Given /^the user "(.*)" is waiting for players$/ do |username|
  user = User.find_by(name: username)
  WaitingPlayer.create(user_id: user.id, active: true)
end