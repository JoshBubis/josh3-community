module Api
  module V1
    class BaseController < ActionController::API
      private

      def current_user
        @current_user
      end

      def authenticate_token!
        raw = request.authorization.to_s.sub(/\ABearer\s+/i, "").strip
        token = ApiToken.authenticate(raw)
        if token
          token.update_column(:last_used_at, Time.current)
          @current_user = token.user
        else
          render json: { error: "Missing or invalid API token." }, status: :unauthorized
        end
      end

      def page_of(scope)
        page = [ params[:page].to_i, 1 ].max
        rows = scope.offset((page - 1) * 25).limit(26).to_a
        next_page = rows.size > 25 ? page + 1 : nil
        [ rows.first(25), page, next_page ]
      end

      def sort_param
        params[:sort].to_s == "new" ? "new" : "hot"
      end
    end
  end
end
