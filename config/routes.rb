Bees::Application.routes.draw do
  use_doorkeeper

  authenticated :user do
    root to: 'apiaries#index', as: 'authenticated_root'
  end

  root 'static_pages#index'

  get '/data', to: 'static_pages#data'

  namespace :api do
    namespace :data do
      resources :harvests, only: [:index]
      resources :hives, only: [:index]
      resources :inspections, only: [:index]
    end

    namespace :mobile do
      resources :apiaries
    end
  end

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

  devise_for :users
end
