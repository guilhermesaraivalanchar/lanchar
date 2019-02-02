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
  resources :filtros
  resources :equipamentos


  # Ajax
  match "/creditar" => "users#creditar", via: [:get, :post]
  match "/desativar_ativar" => "users#desativar_ativar", via: [:get, :post]
  match "/desativar_ativar_produto" => "produtos#desativar_ativar_produto", via: [:get, :post]
  
  match "/setar_cardapio" => "cardapios#setar_cardapio", as: :setar_cardapio, via: [:get, :post]
  match "/get_dados_combo" => "compras#get_dados_combo", as: :get_dados_combo, via: [:get, :post]
  match "/enviar_confirmacao_compra" => "compras#enviar_confirmacao_compra", as: :enviar_confirmacao_compra, via: [:get, :post]
  match "/transferencia_gerais/transferencia_pdf/:id" => "transferencia_gerais#transferencia_pdf", as: :transferencia_pdf, via: [:get, :post]
  match "/transferencia_gerais/transferencia_completa_pdf/:id" => "transferencia_gerais#transferencia_completa_pdf", as: :transferencia_completa_pdf, via: [:get, :post]
  match "/pagina_sem_permissao" => "application#pagina_sem_permissao", as: :pagina_sem_permissao, via: [:get, :post]
  match "/cancelar_transferencia/:id" => "transferencia_gerais#cancelar_transferencia", as: :cancelar_transferencia, via: [:get, :post]
  match "/resetar_senha" => "users#resetar_senha", as: :resetar_senha, via: [:get, :post]
  match "/index_responsavel" => "users#index_responsavel", as: :index_responsavel, via: [:get, :post]
  match "/relatorio_transferencia" => "relatorios#relatorio_transferencia", as: :relatorio_transferencia, via: [:get, :post]
  match "/relatorio_usuario" => "relatorios#relatorio_usuario", as: :relatorio_usuario, via: [:get, :post]
  match "/verificar_quantidade_produto" => "compras#verificar_quantidade_produto", as: :verificar_quantidade_produto, via: [:get, :post]
  match "/login_equipamento" => "equipamentos#login_equipamento", as: :login_equipamento, via: [:get, :post]
  match "/equipamento_page" => "equipamentos#equipamento_page", as: :equipamento_page, via: [:get, :post]
  match "/login_totem" => "equipamentos#login_totem", as: :login_totem, via: [:get, :post]
  match "/finalizar_compra" => "equipamentos#finalizar_compra", as: :finalizar_compra, via: [:get, :post]

  # Filtros
  match "/salvar_filtro" => "filtros#salvar_filtro", as: :salvar_filtro, via: [:get, :post]


  # TOTEM
  match "/totem/login" => "totens#login", via: [:get, :post]
  match "/totem/g_p" => "totens#get_produtos", via: [:get, :post]

end
