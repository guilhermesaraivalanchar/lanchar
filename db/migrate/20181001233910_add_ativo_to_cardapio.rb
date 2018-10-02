class AddAtivoToCardapio < ActiveRecord::Migration[5.2]
  def change
    add_column :cardapios, :ativo, :boolean
  end
end
