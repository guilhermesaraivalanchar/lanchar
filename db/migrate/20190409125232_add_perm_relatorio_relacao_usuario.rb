class AddPermRelatorioRelacaoUsuario < ActiveRecord::Migration[5.2]
  def change
	Permissao.create(permissao_nome: "Relatório Relação Usuários", permissao_codigo: "relatorio_relacao_usuarios", permissao_grupo: "Relatórios")
  end
end
