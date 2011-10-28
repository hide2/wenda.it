WendaIt::Application.routes.draw do

  root :to => "welcome#index"

  resources :sessions do
    collection do
      get 'problem'
      post 'google_login'
      get 'douban_login'
      get 'sina_login'
    end
  end

  resources :questions do
    member do
      post 'vote'
    end
  end
  resources :answers do
    member do
      post 'vote'
      post 'best_answer'
    end
  end
  resources :comments
  resources :tags do
    collection do
      get 'search'
    end
  end
  resources :users do
    collection do
      get 'search'
    end
  end
  resources :badges

  match 'signup' => 'users#signup'
  match 'login' => 'users#login'
  match 'logout' => 'users#logout'

  match 'unanswered' => 'questions#unanswered'
  match 'answered' => 'questions#answered'
  match 'questions/preview' => 'questions#preview'
  match 'questions/tagged/:tag' => 'questions#tagged', :constraints => { :tag => /.*/ }
  match 'search' => 'questions#search'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
