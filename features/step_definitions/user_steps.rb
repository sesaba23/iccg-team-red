Given /^the following users exist:$/ do |users_table|
  users_table.hashes.each do |user|
    User.create(:name => user['name'], :email => user['email'], :password => "foobar", :password_confirmation => "foobar", :admin => false)
  end
end