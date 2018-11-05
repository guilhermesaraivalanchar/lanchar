class CreateBloqueioProdutos < ActiveRecord::Migration[5.2]
  def change
    create_table :bloqueio_produtos do |t|
      t.integer :produto_id
      t.integer :user_id

      t.timestamps
    end
  end
end
