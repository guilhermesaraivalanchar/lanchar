class AddPermsFiltroTotem < ActiveRecord::Migration[5.2]
  def change
  	Permissao.create(permissao_nome: "Ver Filtro Totem", permissao_codigo: "ver_filtro_totem", permissao_grupo: "Filtro Totem")
	Permissao.create(permissao_nome: "Criar Filtro Totem", permissao_codigo: "criar_filtro_totem", permissao_grupo: "Filtro Totem")
	Permissao.create(permissao_nome: "Editar Filtro Totem", permissao_codigo: "editar_filtro_totem", permissao_grupo: "Filtro Totem")
	Permissao.create(permissao_nome: "Deletar Filtro Totem", permissao_codigo: "deletar_filtro_totem", permissao_grupo: "Filtro Totem")

  end
end
