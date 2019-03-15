class AddAtivoToCardapioCombo < ActiveRecord::Migration[5.2]
  def change
    add_column :cardapio_combos, :ativo, :boolean
  end
end
