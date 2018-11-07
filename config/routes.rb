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
  resources :escolas
  resources :fornecedores
  resources :entrada_produtos
  resources :transferencia_gerais

  # Ajax
  match "/creditar" => "users#creditar", via: [:get, :post]
  
  match "/setar_cardapio" => "cardapios#setar_cardapio", as: :setar_cardapio, via: [:get, :post]
  match "/get_dados_combo" => "compras#get_dados_combo", as: :get_dados_combo, via: [:get, :post]
  match "/enviar_confirmacao_compra" => "compras#enviar_confirmacao_compra", as: :enviar_confirmacao_compra, via: [:get, :post]
  match "/transferencia_gerais/transferencia_pdf/:id" => "transferencia_gerais#transferencia_pdf", as: :transferencia_pdf, via: [:get, :post]
  match "/transferencia_gerais/transferencia_completa_pdf/:id" => "transferencia_gerais#transferencia_completa_pdf", as: :transferencia_completa_pdf, via: [:get, :post]
  match "/pagina_sem_permissao" => "application#pagina_sem_permissao", as: :pagina_sem_permissao, via: [:get, :post]
  match "/cancelar_transferencia/:id" => "transferencia_gerais#cancelar_transferencia", as: :cancelar_transferencia, via: [:get, :post]
  match "/resetar_senha" => "users#resetar_senha", as: :resetar_senha, via: [:get, :post]
  match "/index_responsavel" => "users#index_responsavel", as: :index_responsavel, via: [:get, :post]

end
