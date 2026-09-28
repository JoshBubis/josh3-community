class VotesController < ApplicationController
  before_action :require_user

  def create
    votable = find_votable
    if votable.nil? || (votable.respond_to?(:removed?) && votable.removed?)
      redirect_back fallback_location: root_path, alert: "That item cannot be voted on."
      return
    end

    Vote.cast!(user: current_user, votable: votable, direction: params[:direction])
    redirect_back fallback_location: votable.is_a?(Post) ? votable : votable.post
  end

  private

  def find_votable
    case params[:votable_type]
    when "Post" then Post.find_by(id: params[:votable_id])
    when "Comment" then Comment.find_by(id: params[:votable_id])
    end
  end
end
