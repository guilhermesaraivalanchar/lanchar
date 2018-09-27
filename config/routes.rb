Rails.application.routes.draw do

  get 'compras/index'
  root to: 'application#index'

  devise_for :users
  devise_scope :user do
		get 'sign_in', to: 'devise/sessions#new'
	end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


  resources :users, except: [:show], path: "/controle_de_usuarios"
  resources :produtos
  resources :tipo_users
  resources :combos
  resources :compras

  # Ajax
  match "/creditar" => "users#creditar", via: [:get, :post]

  
end
