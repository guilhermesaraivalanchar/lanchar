class AddCanceladoToTransferencias < ActiveRecord::Migration[5.2]
  def change
	add_column :transferencia_gerais, :cancelada, :boolean
	add_column :transferencias, :cancelada, :boolean
	add_column :transferencia_combos, :cancelada, :boolean
  end
end
