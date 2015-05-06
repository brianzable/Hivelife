Bees::Application.routes.draw do
  root 'static_pages#index'

  get '/data', to: 'static_pages#data'
  post '/sign_in', to: 'sessions#sign_in'

  resources :apiaries do
  	resources :hives, except: [:index]
    resources :beekeepers, except: [:index, :new, :edit] do
      post 'preview', on: :new
    end
  end

  resources :hives do
  	resources :inspections, except: [:index]
  	resources :harvests, except: [:index]
  end

  resources :users, except: [:index, :new, :edit]
end
