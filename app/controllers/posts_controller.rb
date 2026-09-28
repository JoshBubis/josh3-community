class PostsController < ApplicationController
  before_action :require_user, only: [ :new, :create ]

  def show
    @post = Post.includes(:user, :channel, comments: :user).find(params[:id])
    @comment = Comment.new
    @comments_by_parent = @post.comments.includes(:user).order(:created_at).group_by(&:parent_id)
  end

  def new
    @post = Post.new(channel_id: Channel.find_by(slug: params[:channel])&.id)
    @channels = Channel.listed
  end

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      redirect_to @post, notice: "Posted."
    else
      @channels = Channel.listed
      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(:channel_id, :title, :body, :link_url)
  end
end
