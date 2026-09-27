class ChannelsController < ApplicationController
  def show
    @channel = Channel.find_by!(slug: params[:slug])
    @sort = params[:sort].to_s == "new" ? "new" : "hot"
    @posts = @channel.posts.visible.includes(:user, :channel).ranked(@sort).limit(50)
  end
end
