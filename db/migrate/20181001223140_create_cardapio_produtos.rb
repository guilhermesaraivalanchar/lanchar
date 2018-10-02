class CreateCardapioProdutos < ActiveRecord::Migration[5.2]
  def change
    create_table :cardapio_produtos do |t|
      t.integer :produto_id
      t.integer :cardapio_id
      t.decimal :preco, precision: 10, scale: 2

      t.timestamps
    end
  end
end
