class CriarPermissoesIniciais < ActiveRecord::Migration[5.2]
  def change
	# Usuário
	Permissao.create(permissao_nome: "Ver Usuários", permissao_codigo: "ver_usuarios", permissao_grupo: "Usuários")
	Permissao.create(permissao_nome: "Criar Usuários", permissao_codigo: "criar_usuarios", permissao_grupo: "Usuários")
	Permissao.create(permissao_nome: "Editar Usuários", permissao_codigo: "editar_usuarios", permissao_grupo: "Usuários")
	Permissao.create(permissao_nome: "Deletar Usuários", permissao_codigo: "deletar_usuarios", permissao_grupo: "Usuários")
	Permissao.create(permissao_nome: "Creditar Usuários", permissao_codigo: "creditar_usuarios_tabela", permissao_grupo: "Usuários")
	Permissao.create(permissao_nome: "Creditar Usuários Dependentes", permissao_codigo: "creditar_usuarios_dependentes", permissao_grupo: "Usuários")
	
	# Tipo de Usuário
	Permissao.create(permissao_nome: "Ver Tipo de Usuários", permissao_codigo: "ver_tipo_usuarios", permissao_grupo: "Tipo de Usuários")
	Permissao.create(permissao_nome: "Criar Tipo de Usuários", permissao_codigo: "criar_tipo_usuarios", permissao_grupo: "Tipo de Usuários")
	Permissao.create(permissao_nome: "Editar Tipo de Usuários", permissao_codigo: "editar_tipo_usuarios", permissao_grupo: "Tipo de Usuários")
	Permissao.create(permissao_nome: "Deletar Tipo de Usuários", permissao_codigo: "deletar_tipo_usuarios", permissao_grupo: "Tipo de Usuários")

	# Produtos
	Permissao.create(permissao_nome: "Ver Produtos", permissao_codigo: "ver_produtos", permissao_grupo: "Produtos")
	Permissao.create(permissao_nome: "Criar Produtos", permissao_codigo: "criar_produtos", permissao_grupo: "Produtos")
	Permissao.create(permissao_nome: "Editar Produtos", permissao_codigo: "editar_produtos", permissao_grupo: "Produtos")
	Permissao.create(permissao_nome: "Deletar Produtos", permissao_codigo: "deletar_produtos", permissao_grupo: "Produtos")

	# Combo
	Permissao.create(permissao_nome: "Ver Combos", permissao_codigo: "ver_combos", permissao_grupo: "Combos")
	Permissao.create(permissao_nome: "Criar Combos", permissao_codigo: "criar_combos", permissao_grupo: "Combos")
	Permissao.create(permissao_nome: "Editar Combos", permissao_codigo: "editar_combos", permissao_grupo: "Combos")
	Permissao.create(permissao_nome: "Deletar Combos", permissao_codigo: "deletar_combos", permissao_grupo: "Combos")

	# Cardapio
	Permissao.create(permissao_nome: "Ver Cardápios", permissao_codigo: "ver_cardapio", permissao_grupo: "Cardápios")
	Permissao.create(permissao_nome: "Criar Cardápios", permissao_codigo: "criar_cardapio", permissao_grupo: "Cardápios")
	Permissao.create(permissao_nome: "Editar Cardápios", permissao_codigo: "editar_cardapio", permissao_grupo: "Cardápios")
	Permissao.create(permissao_nome: "Deletar Cardápios", permissao_codigo: "deletar_cardapio", permissao_grupo: "Cardápios")
	Permissao.create(permissao_nome: "Definir Cardápios", permissao_codigo: "definir_cardapio", permissao_grupo: "Cardápios")

	# Comprar
	Permissao.create(permissao_nome: "Comprar (Sistema)", permissao_codigo: "comprar_sistema", permissao_grupo: "Comprar")
	
	# Tipo de Produto
	Permissao.create(permissao_nome: "Ver Tipo de Prouduto", permissao_codigo: "ver_tipo_produtos", permissao_grupo: "Tipo de Prouduto")
	Permissao.create(permissao_nome: "Criar Tipo de Prouduto", permissao_codigo: "criar_tipo_produtos", permissao_grupo: "Tipo de Prouduto")
	Permissao.create(permissao_nome: "Editar Tipo de Prouduto", permissao_codigo: "editar_tipo_produtos", permissao_grupo: "Tipo de Prouduto")
	Permissao.create(permissao_nome: "Deletar Tipo de Prouduto", permissao_codigo: "deletar_tipo_produtos", permissao_grupo: "Tipo de Prouduto")
  end
end
