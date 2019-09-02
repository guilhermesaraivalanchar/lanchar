class AddCToTransferencia < ActiveRecord::Migration[5.2]
  def change
    add_reference :transferencias, :caixa, index: true
  end
end
