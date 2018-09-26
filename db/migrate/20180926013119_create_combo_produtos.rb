class CreateComboProdutos < ActiveRecord::Migration[5.2]
  def change
    create_table :combo_produtos do |t|
      t.integer :produto_id
      t.integer :combo_id

      t.timestamps
    end
  end
end
