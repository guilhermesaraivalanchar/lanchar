class AddCanceladasToTransferencia < ActiveRecord::Migration[5.2]
  def change
    add_column :transferencias, :data_cancelada, :datetime
    add_reference :transferencias, :user_cancelou, index: true
  end
end
