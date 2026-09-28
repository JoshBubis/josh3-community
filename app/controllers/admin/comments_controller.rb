module Admin
  class CommentsController < ApplicationController
    before_action :require_admin

    def update
      comment = Comment.find(params[:id])
      comment.update!(removed: params[:removed] == "1") if params.key?(:removed)
      redirect_to comment.post, notice: "Comment updated."
    end
  end
end
