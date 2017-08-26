Given /^the user "(.*)" is loggedin$/ do |username|
  user = User.find_by(name: username)
  visit('/login')
  fill_in("Email", :with => user.email)
  fill_in("Password", :with => "foobar")
  click_button("Log in")
end