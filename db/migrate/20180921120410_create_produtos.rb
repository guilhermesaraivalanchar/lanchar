class CreateProdutos < ActiveRecord::Migration[5.2]
  def change
    create_table :produtos do |t|
      t.integer :codigo
      t.string :nome
      t.integer :cod_desconto
      t.integer :quantidade
      t.string :status

      t.timestamps
    end
  end
end
