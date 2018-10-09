class ChangeComboIdToProdutoIdInTransferenciaCombo < ActiveRecord::Migration[5.2]
  def change
  	    remove_column :transferencia_combos, :combo_id
    	add_column :transferencia_combos, :produto_id, :integer
  end
end
