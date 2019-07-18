class PermiEditarEscola < ActiveRecord::Migration[5.2]
  def change
	Permissao.create(permissao_nome: "Editar Escola", permissao_codigo: "editar_escola", permissao_grupo: "Escola")
  end
end
