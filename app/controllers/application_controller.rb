class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Just for testing Heroku deployment
  def hello
    render html: "hello, world!"
  end
end
