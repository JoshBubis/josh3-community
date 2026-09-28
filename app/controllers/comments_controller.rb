class CommentsController < ApplicationController
  before_action :require_user

  def create
    post = Post.find(params[:post_id])
    if post.locked? || post.removed?
      redirect_to post, alert: "This post is not open for comments."
      return
    end

    comment = post.comments.new(comment_params)
    comment.user = current_user
    if comment.save
      redirect_to post_path(post, anchor: "comment-#{comment.id}"), notice: "Comment posted."
    else
      redirect_to post, alert: comment.errors.full_messages.to_sentence
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end
end
