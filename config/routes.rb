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

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
