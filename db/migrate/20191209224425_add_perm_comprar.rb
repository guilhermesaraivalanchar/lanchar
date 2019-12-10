class AddPermComprar < ActiveRecord::Migration[5.2]
  def change
	Permissao.create(permissao_nome: "Comprar", permissao_codigo: "user_comprar", permissao_grupo: "Venda")
  end
end
