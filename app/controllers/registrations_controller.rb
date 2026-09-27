class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      reset_session
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Account created. You are responsible for everything this account posts."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation, :bio, :avatar, :accepted_terms)
  end
end
