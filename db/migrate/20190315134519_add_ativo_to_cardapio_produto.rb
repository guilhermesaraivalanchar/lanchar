class AddAtivoToCardapioProduto < ActiveRecord::Migration[5.2]
  def change
    add_column :cardapio_produtos, :ativo, :boolean
  end
end
