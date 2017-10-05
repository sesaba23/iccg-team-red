source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.3'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3' # Heroku doesn't support SQLite, so we need to use only in development
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.11'
# Use to allow drop down boxes when neccesary
gem 'jquery-rails', '4.3.1'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use use haml for views and templates instead HTML
gem 'haml'


# Use of twitter's bootstrap framework to CSS styles
gem 'bootstrap-sass', '3.3.7'

# Use for paginate a large number of registers
gem 'will_paginate',           '3.1.5'
gem 'bootstrap-will_paginate', '1.0.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'selenium-webdriver'
  # Use sqlite3 as the database for Active Record
  # Heroku does not support sqlite3
  gem 'sqlite3', '1.3.13'

  gem 'factory_girl_rails'
end

group :test do
  # We are going to use BDD (Cucumber and Capybara) and TDD (RSpec)
  gem 'rspec-rails'
  gem 'cucumber-rails', :require => false
  gem 'cucumber-rails-training-wheels'
  gem 'database_cleaner'
  gem 'capybara' # Cucumber will pretend to be a browser
  gem 'launchy' #a useful debugging aid for user stories

  # Autoexecute BDD and TDD if neccessary
  gem 'guard-rspec'
  gem 'autotest-rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # will allow us to make sample users with semi-realistic names and email addresses
  gem 'faker',          '1.7.3'
end

group :production do
  #Added Postgresql to deploy in heroku production server instead SQLite
  gem 'pg', '0.18.4'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
