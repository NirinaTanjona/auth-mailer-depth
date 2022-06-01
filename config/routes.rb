Rails.application.routes.draw do
  root 'static_pages#home'

  get "sign-up", to: "users#new"
  post "sign-up", to: "users#create"

  # Here we are overriding named routes parameters. The default resource identifier is `:id`
  # so instead of /confirmations/:id
  # we have /confirmations/:confirmation_token
  resources :confirmations, only: [:create, :edit, :new], param: :confirmation_token
end
