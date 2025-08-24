Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "/healthz", to: proc { [200, {}, ["OK"]] }

  namespace :api do
    mount_devise_token_auth_for 'User', at: 'auth'

    post 'authenticate', to: 'authentication#authenticate'

  resources :users
  resources :subscriptions do
    collection do
      get :analytics
    end
  end

  resources :movements do
      collection do
        post :import
      end
    end
    resources :dashboard, only: [:index]
  end
end
