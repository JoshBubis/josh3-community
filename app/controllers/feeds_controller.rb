class FeedsController < ApplicationController
  def show
    @sort = params[:sort].to_s == "new" ? "new" : "hot"
    @posts = Post.visible.includes(:user, :channel).ranked(@sort).limit(50)
    @channels = Channel.listed
  end
end
