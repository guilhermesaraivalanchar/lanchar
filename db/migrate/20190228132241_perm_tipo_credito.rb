class PermTipoCredito < ActiveRecord::Migration[5.2]
  def change
  	Permissao.create(permissao_nome: "Ver Tipo de Credito", permissao_codigo: "ver_tipo_creditos", permissao_grupo: "Tipo de Credito")
	Permissao.create(permissao_nome: "Criar Tipo de Credito", permissao_codigo: "criar_tipo_creditos", permissao_grupo: "Tipo de Credito")
	Permissao.create(permissao_nome: "Editar Tipo de Credito", permissao_codigo: "editar_tipo_creditos", permissao_grupo: "Tipo de Credito")
	Permissao.create(permissao_nome: "Deletar Tipo de Credito", permissao_codigo: "deletar_tipo_creditos", permissao_grupo: "Tipo de Credito")
  end
end
