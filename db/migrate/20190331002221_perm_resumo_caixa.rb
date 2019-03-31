class PermResumoCaixa < ActiveRecord::Migration[5.2]
  def change
	Permissao.create(permissao_nome: "Ver Resumo Caixa", permissao_codigo: "resumo_caixa", permissao_grupo: "Escola")
  end
end
