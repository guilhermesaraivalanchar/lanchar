class AddTipoProdutoToProduto < ActiveRecord::Migration[5.2]
  def change
    add_column :produtos, :tipo_produto_id, :integer
  end
end
