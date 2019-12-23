Rails.application.routes.draw do

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"

  root to: 'application#index'

  devise_for :users
  
  
  devise_scope :user do
    get '/CBS', to: 'devise/sessions#new', :escola => 1
    get '/cbs', to: 'devise/sessions#new', :escola => 1
		#get 'sign_in', to: 'devise/sessions#new'
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
  resources :filtro_totens
  resources :tipo_creditos
  resources :downloads
  resources :demanda_entradas


  # Ajax
  match "/login_acesso" => "users#login_acesso", as: :login_acesso, via: [:get, :post]


  match "/creditar" => "users#creditar", via: [:get, :post]
  match "/desativar_ativar" => "users#desativar_ativar", via: [:get, :post]
  match "/desativar_ativar_produto" => "produtos#desativar_ativar_produto", via: [:get, :post]
  
  match "/setar_cardapio" => "cardapios#setar_cardapio", as: :setar_cardapio, via: [:get, :post]
  match "/get_dados_combo" => "compras#get_dados_combo", as: :get_dados_combo, via: [:get, :post]
  match "/enviar_confirmacao_compra" => "compras#enviar_confirmacao_compra", as: :enviar_confirmacao_compra, via: [:get, :post]
  match "/transferencia_gerais/transferencia_pdf/:id" => "transferencia_gerais#transferencia_pdf", as: :transferencia_pdf, via: [:get, :post]
  match "/transferencia_gerais/transferencia_completa_pdf/:id" => "transferencia_gerais#transferencia_completa_pdf", as: :transferencia_completa_pdf, via: [:get, :post]
  match "/pagina_sem_permissao" => "application#pagina_sem_permissao", as: :pagina_sem_permissao, via: [:get, :post]
  match "/cancelar_transferencia" => "transferencia_gerais#cancelar_transferencia", as: :cancelar_transferencia, via: [:get, :post]
  match "/cancelar_transferencia_unica" => "transferencia_gerais#cancelar_transferencia_unica", as: :cancelar_transferencia_unica, via: [:get, :post]
  match "/resetar_senha" => "users#resetar_senha", as: :resetar_senha, via: [:get, :post]
  match "/index_responsavel" => "users#index_responsavel", as: :index_responsavel, via: [:get, :post]
  match "/relatorio_transferencia" => "relatorios#relatorio_transferencia", as: :relatorio_transferencia, via: [:get, :post]
  match "/relatorio_usuario" => "relatorios#relatorio_usuario", as: :relatorio_usuario, via: [:get, :post]
  match "/relatorio_relacao_responsavel" => "relatorios#relatorio_relacao_responsavel", as: :relatorio_relacao_responsavel, via: [:get, :post]
  match "/verificar_quantidade_produto" => "compras#verificar_quantidade_produto", as: :verificar_quantidade_produto, via: [:get, :post]
  match "/login_equipamento" => "equipamentos#login_equipamento", as: :login_equipamento, via: [:get, :post]
  match "/equipamento_page" => "equipamentos#equipamento_page", as: :equipamento_page, via: [:get, :post]
  match "/login_totem" => "equipamentos#login_totem", as: :login_totem, via: [:get, :post]
  match "/check_login_cartao_sem_senha" => "equipamentos#check_login_cartao_sem_senha", as: :check_login_cartao_sem_senha, via: [:get, :post]
  match "/finalizar_compra" => "equipamentos#finalizar_compra", as: :finalizar_compra, via: [:get, :post]
  match "/alt_senha_user" => "equipamentos#alt_senha_user", as: :alt_senha_user, via: [:get, :post]
  match "/resetar_senha_totem" => "users#resetar_senha_totem", as: :resetar_senha_totem, via: [:get, :post]
  match "/transferencia_saldo" => "users#transferencia_saldo", as: :transferencia_saldo, via: [:get, :post]
  match "/transferencia_saldo_pai" => "users#transferencia_saldo_pai", as: :transferencia_saldo_pai, via: [:get, :post]
  match "/transferencia_saldo_info" => "users#transferencia_saldo_info", as: :transferencia_saldo_info, via: [:get, :post]
  match "/transferir_saldo" => "users#transferir_saldo", as: :transferir_saldo, via: [:get, :post]
  match "/cardapio_pais" => "cardapios#cardapio_pais", as: :cardapio_pais, via: [:get, :post]
  match "/resumo_caixa" => "escolas#resumo_caixa", as: :resumo_caixa, via: [:get, :post]
  match "/ajuste_saldo" => "escolas#ajuste_saldo", as: :ajuste_saldo, via: [:get, :post]
  match "/definir_integracao_sponte" => "escolas#definir_integracao_sponte", as: :definir_integracao_sponte, via: [:get, :post]
  match "/integrar_alunos" => "escolas#integrar_alunos", as: :integrar_alunos, via: [:get, :post]
  match "/central_aluno" => "users#central_aluno", as: :central_aluno, via: [:get, :post]

  match "/preco_cardapio_produto" => "cardapios#preco_cardapio_produto", as: :preco_cardapio_produto, via: [:get, :post]
  match "/preco_cardapio_combo" => "cardapios#preco_cardapio_combo", as: :preco_cardapio_combo, via: [:get, :post]
  match "/ativo_cardapio_produto" => "cardapios#ativo_cardapio_produto", as: :ativo_cardapio_produto, via: [:get, :post]
  match "/ativo_cardapio_combo" => "cardapios#ativo_cardapio_combo", as: :ativo_cardapio_combo, via: [:get, :post]
  match "/desabilitar_saldo_diario" => "escolas#desabilitar_saldo_diario", as: :desabilitar_saldo_diario, via: [:get, :post]

  match "/produtos_vendidos" => "produtos#produtos_vendidos", as: :produtos_vendidos, via: [:get, :post]

  match "/escola_hist_transacao" => "escolas#escola_hist_transacao", as: :escola_hist_transacao, via: [:get, :post, :patch]
  match "/dash_vendas_entradas" => "escolas#dash_vendas_entradas", as: :dash_vendas_entradas, via: [:get, :post, :patch]

  match "/mudar_cor_escola" => "escolas#mudar_cor_escola", as: :mudar_cor_escola, via: [:get, :post, :patch]

  # Filtros
  match "/salvar_filtro" => "filtros#salvar_filtro", as: :salvar_filtro, via: [:get, :post]

  # TOTEM
  match "/totem/login" => "totens#login", via: [:get, :post]
  match "/totem/g_p" => "totens#get_produtos", via: [:get, :post]

  match "/resumo_escola" => "escolas#resumo_escola", as: :resumo_escola, via: [:get, :post]

  match "/criar_relatorio" => "relatorios#criar_relatorio", via: [:get, :post]

  match "/get_resumo_escola" => "escolas#get_resumo_escola", via: [:get, :post]

  match "/mudar_saldo_dependente" => "users#mudar_saldo_dependente", via: [:get, :post]

  match "/segunda_via" => "transferencia_gerais#segunda_via", via: [:get, :post]

  match "/get_users" => "users#get_users", via: [:get,:post]
  match "/get_user_central" => "users#get_user_central", via: [:get,:post]

end
