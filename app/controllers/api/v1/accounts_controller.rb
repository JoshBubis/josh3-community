module Api
  module V1
    class AccountsController < BaseController
      before_action :authenticate_token!

      def show
        render json: ApiResource.user(current_user, self, include_email: true)
      end

      def update
        if current_user.update(bio: params[:bio])
          render json: ApiResource.user(current_user, self, include_email: true)
        else
          render json: { error: current_user.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end
    end
  end
end
