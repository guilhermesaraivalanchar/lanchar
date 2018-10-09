Rails.application.routes.draw do

  root to: 'application#index'

  devise_for :users
  devise_scope :user do
		get 'sign_in', to: 'devise/sessions#new'
	end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


  resources :users, path: "/controle_de_usuarios"
  resources :produtos
  resources :tipo_users
  resources :combos
  resources :compras
  resources :cardapios
  resources :tipo_produtos

  # Ajax
  match "/creditar" => "users#creditar", via: [:get, :post]
  
  match "/setar_cardapio" => "cardapios#setar_cardapio", as: :setar_cardapio, via: [:get, :post]
  match "/get_dados_combo" => "compras#get_dados_combo", as: :get_dados_combo, via: [:get, :post]
  match "/enviar_confirmacao_compra" => "compras#enviar_confirmacao_compra", as: :enviar_confirmacao_compra, via: [:get, :post]
  match "/transferencia_gerais/transferencia_pdf/:id" => "transferencia_gerais#transferencia_pdf", as: :transferencia_pdf, via: [:get, :post]

end
