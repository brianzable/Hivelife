Bees::Application.routes.draw do
  scope :v1 do
    scope :api do
      get '/data', to: 'static_pages#data'
      post '/sign_in', to: 'sessions#sign_in'

      resources :apiaries do
        resources :hives, except: [:new, :edit]
        resources :beekeepers, except: [:new, :edit]
      end

      resources :hives do
        resources :inspections, except: [:new, :edit]
        resources :harvests, except: [:new, :edit]
      end

      get '/users/:activation_token/activate', to: 'users#activate'
      resources :users, except: [:index, :new, :edit]
    end
  end
end
