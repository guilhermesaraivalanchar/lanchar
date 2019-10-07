class AddEquipamentoToTransferencia < ActiveRecord::Migration[5.2]
  def change
    add_reference :transferencias, :equipamento, index: true
  end
end
