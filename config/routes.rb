Rails.application.routes.draw do
  get "pages/home"
  get "pages/contact"
  get "pages/about"
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Galleries (public index/show, admin CRUD + reorder)
  resources :galleries do
    patch :reorder, on: :member
  end

  # Events (public index/show, admin CRUD)
  resources :events

  # Members (admin only)
  resources :members

  # Image management (admin only)
  namespace :admin do
    resources :images, only: %i[index new create destroy] do
      post :sync, on: :collection
    end
  end

  # Calendar (public)
  get "calendar", to: "calendar#show", as: :calendar

  # Defines the root path route ("/")
  root "pages#home"

  get "/404", to: "errors#not_found"
  get "/500", to: "errors#internal_server_error"
  # Add a catch-all route at the very bottom to handle unfound routes
  match "*path", to: "errors#not_found", via: :all
end
