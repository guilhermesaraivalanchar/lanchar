class AddValorToTransferencias < ActiveRecord::Migration[5.2]
  def change
	add_column :transferencias, :valor, :float
  end
end
