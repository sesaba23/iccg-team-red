# Cucumber steps regarding user actions

Given /^the following users exist:$/ do |users_table|
  users_table.hashes.each do |user|
    User.create(:name => user['name'], :email => user['email'], 
      :password => user['password'], :password_confirmation => user['password'], 
      :admin => user['admin'])
  end
end

Given /^the user "(.*)" is log-in$/ do |username|
  user = User.find_by(name: username)
  visit('/login')
  fill_in("Email", :with => user.email)
  fill_in("Password", :with => "foobar")
  click_button("Log in")
end