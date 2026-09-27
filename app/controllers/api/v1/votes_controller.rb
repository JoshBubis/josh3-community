module Api
  module V1
    class VotesController < BaseController
      before_action :authenticate_token!

      def create
        votable = find_votable
        if votable.nil?
          render json: { error: "Not found." }, status: :not_found
          return
        end
        if votable.respond_to?(:removed?) && votable.removed?
          render json: { error: "Removed items cannot be voted on." }, status: :forbidden
          return
        end
        unless %w[up down clear].include?(params[:direction].to_s)
          render json: { error: "direction must be up, down, or clear." }, status: :unprocessable_entity
          return
        end

        Vote.cast!(user: current_user, votable: votable, direction: params[:direction])
        votable.reload
        payload = votable.is_a?(Post) ? ApiResource.post(votable, self) : ApiResource.comment(votable, self)
        render json: payload
      end

      private

      def find_votable
        if params[:post_id]
          Post.find_by(id: params[:post_id])
        elsif params[:comment_id]
          Comment.find_by(id: params[:comment_id])
        end
      end
    end
  end
end
