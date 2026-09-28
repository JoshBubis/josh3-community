class ApiTokensController < ApplicationController
  before_action :require_user

  def index
    @tokens = current_user.api_tokens.order(created_at: :desc)
    @new_token = flash[:api_token]
  end

  def create
    _record, raw = ApiToken.issue!(user: current_user, name: params[:name].presence || "default")
    flash[:api_token] = raw
    redirect_to api_tokens_path, notice: "Token created. Copy it now. It will not be shown again."
  end

  def destroy
    current_user.api_tokens.find(params[:id]).destroy!
    redirect_to api_tokens_path, notice: "Token revoked."
  end
end
