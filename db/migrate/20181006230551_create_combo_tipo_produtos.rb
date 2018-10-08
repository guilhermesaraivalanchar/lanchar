class CreateComboTipoProdutos < ActiveRecord::Migration[5.2]
  def change
    create_table :combo_tipo_produtos do |t|
      t.integer :tipo_produto_id
      t.integer :combo_id

      t.timestamps
    end
  end
end
