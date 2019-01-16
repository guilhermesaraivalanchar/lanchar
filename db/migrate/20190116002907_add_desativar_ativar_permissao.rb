class AddDesativarAtivarPermissao < ActiveRecord::Migration[5.2]
  def change
  	Permissao.create(permissao_nome: "Ativar/Desativar Usuários", permissao_codigo: "ativar_desativar_usuarios", permissao_grupo: "Usuários")
	Permissao.create(permissao_nome: "Ativar/Desativar Produtos", permissao_codigo: "ativar_desativar_produtos", permissao_grupo: "Produtos")
  end
end
