class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include SessionsHelper

  # Just for testing Heroku deployment
  def hello
    render html: "hello, world!"
  end
end
