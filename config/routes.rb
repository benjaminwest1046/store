Rails.application.routes.draw do
  get 'transactions/new'

  devise_for :users, path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'register' }

  resources :products

  resource :cart, only: [:show] do
    put 'add/:product_id', to: 'carts#add', as: :add_to
    put 'remove/:product_id', to: 'carts#remove', as: :remove_from
  end

  root 'products#index'

  resources :transactions, only: [:new, :create]


end
