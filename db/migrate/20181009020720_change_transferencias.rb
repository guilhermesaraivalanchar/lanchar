class ChangeTransferencias < ActiveRecord::Migration[5.2]
  def change
  	remove_column :transferencias, :user_id
	add_column :transferencias, :transferencia_geral_id, :integer
  end
end
