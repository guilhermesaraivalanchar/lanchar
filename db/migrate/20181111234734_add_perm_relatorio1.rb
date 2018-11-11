class AddPermRelatorio1 < ActiveRecord::Migration[5.2]
  def change
  	Permissao.create(permissao_nome: "Relatório Transação", permissao_codigo: "relatorio_transferencias", permissao_grupo: "Relatórios")
	Permissao.create(permissao_nome: "Relatório Usuário", permissao_codigo: "relatorio_usuario", permissao_grupo: "Relatórios")
  end
end
