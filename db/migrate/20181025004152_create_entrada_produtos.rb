class CreateEntradaProdutos < ActiveRecord::Migration[5.2]
  def change
    create_table :entrada_produtos do |t|
      t.integer :fornecedor_id
      t.integer :produto_id
      t.decimal :preco_custo, precision: 10, scale: 2
      t.integer :quantidade
      t.integer :escola_id

      t.timestamps
    end
  end
end
