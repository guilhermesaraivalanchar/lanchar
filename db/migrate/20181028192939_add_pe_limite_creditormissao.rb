class AddPeLimiteCreditormissao < ActiveRecord::Migration[5.2]
  def change
	Permissao.create(permissao_nome: "Alterar Limite de Credito", permissao_codigo: "limite_credito", permissao_grupo: "Usuários")
  end
end
