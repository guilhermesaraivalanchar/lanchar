class AddPermissaoVerTodosUsuarios < ActiveRecord::Migration[5.2]
  def change
	Permissao.create(permissao_nome: "Ver Usuario", permissao_codigo: "ver_usuario", permissao_grupo: "Usuários")

	Permissao.create(permissao_nome: "Auto Creditar", permissao_codigo: "auto_creditar", permissao_grupo: "Usuários")
	Permissao.create(permissao_nome: "Ver Dados da Escola", permissao_codigo: "ver_escola", permissao_grupo: "Escola")
  end
end
