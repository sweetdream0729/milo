Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  # Devise
  devise_for :users, :controllers => { registrations: 'registrations', sessions: 'sessions' }
    resources :users, :only => [:show] do
    resources :transactions, only: [:index, :show, :edit, :update]
    resources :accounts, only: [:index]
  end

  # User Sign Up Wizard
  resources :after_signup

  # Root, User Logged In
  authenticated :user do
    root 'home#index', as: :authenticated_root
  end
  # Root, User Logged Out
  root 'pages#show', page: 'home'

  # Mobile Phone Verification, TODO :: delete when wizard is created
  post 'verifications' => 'verifications#create'
  patch 'verifications' => 'verifications#verify'

  resources :checkings
  resources :contacts, only: [:new, :create]

  # Pages for Marketing Site
  get '/*page' => 'pages#show'

  post '/users/:id/add_account', to: 'plaidapi#add_account'
  patch '/users/:id/update_accounts', to: 'plaidapi#update_accounts'

  get "/settings" => "settings#index"

end
