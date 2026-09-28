class ProfilesController < ApplicationController
  before_action :require_user, only: [ :edit, :update ]

  def show
    @user = User.find_by!(username: params[:username].to_s.downcase)
    @posts = @user.posts.visible.includes(:channel).ranked("new").limit(50)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to edit_profile_path, notice: "Profile saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:bio, :avatar)
  end
end
