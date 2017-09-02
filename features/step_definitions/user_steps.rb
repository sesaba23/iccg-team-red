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

Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
  end
end

When(/^I am the only player in the queue$/) do
  get '/multiplayer_queues/1/enqueue'
end 

When /^(?:|I )follow "([^"]*)"$/ do |link|
  current_path = URI.parse(current_url).path
  if current_path.eql? '/multiplayer_queues/1/enqueue'
    get '/multiplayer_queues/1/quit'
  end
  click_link(link)
end