Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      defaults format: :json do
        resources :users, only: %i[index show] do
          resources :todos  do
            member do
              patch "update-status", to: "update_status"
            end
          end
        end
        post "users/register", to: "users#create"

        # get "todos/:owner", to: "todos#index"
        post "auth/token", to: "access#token"
      end
    end
  end
  # get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
