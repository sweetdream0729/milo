require 'resque/server'
require 'resque-scheduler'
require 'resque/scheduler/server'

Rails.application.routes.draw do

  # Rails Admin
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # Resque admin
  mount Resque::Server.new, :at => "/resque"

  # Devise
  devise_for :users, :controllers => { registrations: 'registrations', sessions: 'sessions', passwords: 'passwords', invitations: 'invitations' }, :skip => [:sessions, :registrations]
    resources :users, :only => [:show] do
    resources :transactions, only: [:index, :show, :edit, :update]
    resources :accounts, only: [:index, :new, :update]
  end

  devise_scope :user do
    # User Sessions
    get 'login', to: "sessions#new", as: :new_user_session
    post 'login', to: "sessions#create", as: :user_session
    delete 'logout', to: "sessions#destroy", as: :destroy_user_session
    # User Settings
    get 'settings', to: 'registrations#edit', as: :settings
    get 'settings/accounts', to: 'registrations#accounts', as: :settings_accounts
    get 'settings/security', to: 'registrations#security', as: :settings_security
    # User Sign Up
    get 'signup', to: "registrations#new", as: :new_user_registration
    post 'signup', to: "registrations#create", as: :user_registration
    patch 'signup', to: "registrations#update"
    put 'signup', to: "registrations#update"
    get 'signup/phone', to: 'registrations#phone', as: :signup_phone
    get 'signup/phone_confirm', to: 'registrations#phone_confirm', as: :signup_phone_confirm
    get 'signup/on_demand', to: 'registrations#on_demand', as: :signup_on_demand
    # Employer Sign Up
    get 'signup/employer', to: 'registrations#employer', as: :new_employer
    # Employer Contributions Settings
    get 'settings/contributions', to: 'businesses#edit', as: :settings_contributions
    # Root, User Logged In
    authenticated :user do
      root 'home#index', as: :authenticated_root
    end
    # Root, User Logged Out
    unauthenticated do
      root 'sessions#new', as: :unauthenticated_root
    end
  end

  resource :user, only: [:edit] do
    collection do
      patch 'update_password'
    end
  end

  # Employer Leads
  get '/tell-your-employer', to: 'leads#new', as: :employer_lead
  resources "leads", only: [:new, :create]

  resources :businesses, only: [:edit, :update]
  resources :debts
  resources :employees, only: [:index, :destroy]

  get 'history', to: 'home#history', as: :history
  get 'roundups', to: 'home#roundups', as: :roundups
  get 'transfers', to: 'home#transfers', as: :transfers

  # Works
  get '/works', to: 'works#index', as: :works_overview
  get '/works/history', to: 'works#history', as: :works_history

  # Zero
  get '/zero', to: 'zero#index', as: :zero_overview
  get '/zero/progress', to: 'zero#progress', as: :zero_progress
  get '/zero/payments', to: 'zero#payments', as: :zero_payments

  # Mobile Phone Verification
  post 'verifications' => 'verifications#create'
  patch 'verifications' => 'verifications#verify'

  # Verify Bank Account
  get 'accounts/bank_verify', to: 'accounts#bank_verify', as: :signup_bank_verify
  get 'accounts/verify_micro_deposits', to: 'accounts#verify_micro_deposits'

  # Remove Bank Accounts
  get 'accounts/remove', to: 'accounts#remove', as: :accounts_remove

  resources :checkings, only: [:new, :create]
  get 'quick-save', to:'checkings#quick_save'
  resources :goals

  # Error Pages
  get "/404", to: "errors#not_found", via: :all
  get "/500", to: "errors#internal_server_error", via: :all

  # Plaid Link to Connect Bank Account
  post '/users/:id/add_account', to: 'plaidapi#add_account'
  patch '/users/:id/update_accounts', to: 'plaidapi#update_accounts'
  patch '/users/withdraw_funds', to: 'users#withdraw_funds'

  # Doorkeeper for API Protection
  use_doorkeeper

  # Dummy Root for Doorkeeper
  root to: 'static#index'

  # API
  namespace :api do
    namespace :v1 do
      # Users
      resources :sessions, only: [:create, :destroy]
      # devise_for :users
      resources :users, only: [:show, :create, :update, :destroy] do
        collection do
          post :forgot_password
        end
      end
      # Alexa
      namespace :alexa do
        resource :handler, only: [:create]
      end
    end
  end

  # webhook routes
  scope '/webhooks', :controller => :webhooks do
    post :dwolla_webhook
  end

end
