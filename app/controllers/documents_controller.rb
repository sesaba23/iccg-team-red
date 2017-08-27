
class DocumentsController < ApplicationController
  before_action :require_login
  
  def index
    @documents = Document.all
    render "index"
  end

  private

  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this section"
      redirect_to login_path # halts request cycle
    end
  end
  
end
