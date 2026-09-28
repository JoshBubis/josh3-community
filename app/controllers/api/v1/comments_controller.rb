module Api
  module V1
    class CommentsController < BaseController
      before_action :authenticate_token!, only: :create

      def index
        post = Post.find(params[:post_id])
        comments = post.comments.includes(:user).order(:created_at)
        render json: { comments: comments.map { |comment| ApiResource.comment(comment, self) } }
      end

      def create
        post = Post.find(params[:post_id])
        if post.locked? || post.removed?
          render json: { error: "This post is not open for comments." }, status: :forbidden
          return
        end

        comment = post.comments.new(user: current_user, body: params[:body], parent_id: params[:parent_id])
        if comment.save
          render json: ApiResource.comment(comment, self), status: :created
        else
          render json: { error: comment.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end
    end
  end
end
