module Admin
  class PostsController < ApplicationController
    before_action :require_admin

    def update
      post = Post.find(params[:id])
      post.update!(removed: params[:removed] == "1") if params.key?(:removed)
      post.update!(locked: params[:locked] == "1") if params.key?(:locked)
      redirect_to post, notice: "Post updated."
    end
  end
end
