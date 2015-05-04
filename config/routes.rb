Bees::Application.routes.draw do
  root 'static_pages#index'

  get '/data', to: 'static_pages#data'

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
end
