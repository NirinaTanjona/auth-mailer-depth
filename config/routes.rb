Rails.application.routes.draw do
  root 'static_pages#home'

  # registration
  get "sign-up", to: "users#new"
  post "sign-up", to: "users#create"

  get "account", to: "users#edit"
  put "account", to: "users#update"
  delete "account", to: "users#destroy"

  # Here we are overriding named routes parameters. The default resource identifier is `:id`
  # so instead of /confirmations/:id
  # we have /confirmations/:confirmation_token
  resources :confirmations, only: [:create, :edit, :new], param: :confirmation_token
  resources :passwords, only: [:create, :edit, :new, :update], param: :password_reset_token

  # login
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # The destroy_all method is a collection route that will destroy all active_session
  # records associated with the current_user. Note that we call reset_session because
  # we will be logging out the current_user during this request.
  resources :active_sessions, only: [:destroy] do
    collection do
      delete "destroy_all"
    end
  end
end
