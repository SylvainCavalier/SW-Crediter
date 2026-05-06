Rails.application.routes.draw do
  devise_for :users

  # PWA
  get "/service-worker.js", to: "pwa#service_worker", as: :pwa_service_worker, format: :js
  get "manifest" => "pwa#manifest", as: :pwa_manifest

  # Pages
  get "team" => "pages#team", as: :team
  patch "users/:id/avatar_upload", to: "pages#avatar_upload", as: :avatar_upload

  # Choix du nom de personnage à la première connexion (PJ)
  get  "character_name", to: "character_names#new",    as: :new_character_name
  post "character_name", to: "character_names#create", as: :character_name

  # Users (profils simplifiés)
  resources :users, only: [:show] do
    resources :inventory_objects, only: [:index, :create, :destroy]

    member do
      get :settings
      patch :update_settings
    end
  end

  # Transferts de crédits
  resources :transactions, only: [:new, :create]

  # Subventions de la République (Easter egg bureaucratique)
  get 'subsidies', to: 'subsidies#new', as: :new_subsidy
  get 'subsidies/form', to: 'subsidies#form', as: :subsidy_form
  post 'subsidies/submit', to: 'subsidies#submit', as: :submit_subsidy

  # Push notifications
  resources :subscriptions, only: [:create, :destroy]

  # Holonews (messagerie)
  resources :holonews, only: [:index, :new, :create]
  get 'holonews/count', to: 'holonews#count'

  # Contacts (pour holonews)
  resources :contacts, only: [:index] do
    collection do
      post :add
      delete :remove
    end
  end

  # Reparations (scan QR)
  get 'repairs/scan', to: 'repairs#scan', as: :repairs_scan
  get 'repairs/:qr_token', to: 'repairs#show', as: :repair
  post 'repairs/:qr_token/validate', to: 'repairs#validate_code', as: :repair_validate

  # Pazaak (jeu de cartes)
  namespace :pazaak do
    resource :menu, only: :show, controller: :menus
    resource :deck, only: [:show, :update], controller: :decks
    resource :stats, only: :show, controller: :stats
    resources :lobbies, only: :index do
      collection do
        post :ping
      end
    end
    resources :invitations, only: [:create, :update]
    resources :games, only: [:show, :create] do
      member do
        post :abandon
      end
      resources :moves, only: :create
    end
  end
  get "/pazaak", to: "pazaak/menus#show"

  root 'pages#home'
end
