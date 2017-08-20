class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  # We only allow params contain the given atributtes to avoid injections
  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end


end
