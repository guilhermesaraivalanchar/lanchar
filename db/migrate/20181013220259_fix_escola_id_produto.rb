class FixEscolaIdProduto < ActiveRecord::Migration[5.2]
  def change
  	remove_column :produtos, :escola_id
    add_column :produtos, :escola_id, :integer
    remove_column :fornecedores, :escola_id
    add_column :fornecedores, :escola_id, :integer
  end
end
