Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "feeds#show"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "signup", to: "registrations#new"
  post "signup", to: "registrations#create"

  get "terms", to: "pages#terms"
  get "norms", to: "pages#norms"
  get "docs/api", to: "pages#api", as: :api_docs

  # Preserved from the previous static site — must keep working after cutover.
  get "about", to: "pages#about"
  get "reddit/callback", to: "pages#reddit_callback"

  get "settings/profile", to: "profiles#edit", as: :edit_profile
  patch "settings/profile", to: "profiles#update"
  get "u/:username", to: "profiles#show", as: :profile

  resources :api_tokens, only: [ :index, :create, :destroy ]
  resources :channels, only: [ :show ], param: :slug
  resources :posts, only: [ :show, :new, :create ] do
    resources :comments, only: [ :create ]
  end
  resources :votes, only: [ :create ]
  resources :reports, only: [ :create ]

  namespace :admin do
    resources :reports, only: [ :index, :update ]
    resources :posts, only: [ :update ]
    resources :comments, only: [ :update ]
  end

  namespace :api do
    namespace :v1 do
      get "me", to: "accounts#show"
      patch "me", to: "accounts#update"
      get "channels", to: "channels#index"
      get "channels/:slug", to: "channels#show"
      get "posts", to: "posts#index"
      get "channels/:slug/posts", to: "posts#index"
      post "channels/:slug/posts", to: "posts#create"
      get "posts/:id", to: "posts#show"
      get "posts/:post_id/comments", to: "comments#index"
      post "posts/:post_id/comments", to: "comments#create"
      post "posts/:post_id/vote", to: "votes#create"
      post "comments/:comment_id/vote", to: "votes#create"
    end
  end
end
