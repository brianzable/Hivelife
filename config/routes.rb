Bees::Application.routes.draw do
  scope :v1 do
    scope :api do
      post '/sign_in', to: 'sessions#sign_in'

      resources :password_resets, only: [:create, :update]
      resources :contact_requests, only: [:create]

      resources :apiaries do
        resources :hives, except: [:new, :edit]
        resources :beekeepers, except: [:new, :edit]
      end

      resources :hives do
        resources :inspections, except: [:new, :edit] do
          get :defaults, on: :collection
        end
        resources :harvests, except: [:new, :edit]
      end

      get '/users/:activation_token/activate', to: 'users#activate', as: :user_activation
      resources :users, except: [:index, :show, :new, :edit] do
        collection do
          get 'profile', as: :profile
        end
      end
    end
  end
end
