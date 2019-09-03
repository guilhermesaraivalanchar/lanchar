class AddTipoToEntradaProduto < ActiveRecord::Migration[5.2]
  def change
    add_column :entrada_produtos, :tipo, :string
  end
end
