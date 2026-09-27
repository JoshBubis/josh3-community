module Api
  module V1
    class ChannelsController < BaseController
      def index
        render json: { channels: Channel.listed.map { |channel| ApiResource.channel(channel) } }
      end

      def show
        channel = Channel.find_by!(slug: params[:slug])
        render json: ApiResource.channel(channel)
      end
    end
  end
end
