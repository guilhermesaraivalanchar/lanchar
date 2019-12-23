class AddBloqProdutoToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :bloq_produto, :string
  end
end
