class GuessersController < RgController
  before_action :get_guesser

  private
  
  def get_guesser
    @player = Guesser.find(params[:id])
  end
  
end
