class AddSaldoAntToTransferencia < ActiveRecord::Migration[5.2]
  def change
    add_column :transferencias, :saldo_anterior, :decimal, precision: 10, scale: 2
  end
end
