module Api
  module V1
    class PostsController < BaseController
      before_action :authenticate_token!, only: :create

      def index
        scope = Post.visible.includes(:user, :channel).ranked(sort_param)
        if params[:slug].present?
          channel = Channel.find_by!(slug: params[:slug])
          scope = scope.where(channel: channel)
        end
        posts, page, next_page = page_of(scope)
        render json: {
          posts: posts.map { |post| ApiResource.post(post, self) },
          page: page,
          next_page: next_page,
          sort: sort_param
        }
      end

      def show
        post = Post.includes(:user, :channel).find(params[:id])
        render json: ApiResource.post(post, self)
      end

      def create
        channel = Channel.find_by!(slug: params[:slug])
        post = current_user.posts.new(channel: channel, title: params[:title], body: params[:body], link_url: params[:link_url])
        if post.save
          render json: ApiResource.post(post, self), status: :created
        else
          render json: { error: post.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end
    end
  end
end
