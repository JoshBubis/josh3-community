class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate_by(email: params[:email].to_s, password: params[:password].to_s)
    if user
      reset_session
      session[:user_id] = user.id
      redirect_to root_path, notice: "Welcome back."
    else
      flash.now[:alert] = "Email or password is wrong."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Logged out."
  end
end
