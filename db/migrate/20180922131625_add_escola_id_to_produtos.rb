class AddEscolaIdToProdutos < ActiveRecord::Migration[5.2]
  def change
    add_column :produtos, :escola_id, :string
    add_column :fornecedores, :escola_id, :string
  end
end
