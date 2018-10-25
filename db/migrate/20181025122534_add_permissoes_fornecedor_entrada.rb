class AddPermissoesFornecedorEntrada < ActiveRecord::Migration[5.2]
  def change
  	# Comprar
	Permissao.create(permissao_nome: "Entrada Produto (Sistema)", permissao_codigo: "dar_entrada_produto", permissao_grupo: "Entrada Produto")
	
	# Tipo de Produto
	Permissao.create(permissao_nome: "Ver Fornecedores", permissao_codigo: "ver_fornecedores", permissao_grupo: "Fornecedores")
	Permissao.create(permissao_nome: "Criar Fornecedores", permissao_codigo: "criar_fornecedores", permissao_grupo: "Fornecedores")
	Permissao.create(permissao_nome: "Editar Fornecedores", permissao_codigo: "editar_fornecedores", permissao_grupo: "Fornecedores")
	Permissao.create(permissao_nome: "Deletar Fornecedores", permissao_codigo: "deletar_fornecedores", permissao_grupo: "Fornecedores")

	Permissao.create(permissao_nome: "Ver Produto", permissao_codigo: "ver_produto", permissao_grupo: "Produtos")
	
	Permissao.create(permissao_nome: "Ver Transação", permissao_codigo: "ver_transacoes", permissao_grupo: "Transação")
	Permissao.create(permissao_nome: "Cancelar Transação", permissao_codigo: "cancelar_transacao", permissao_grupo: "Transação")

  end
end
