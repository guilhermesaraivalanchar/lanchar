class AddSaldoAnteriorToTransf < ActiveRecord::Migration[5.2]
  def change
    add_column :transferencia_gerais, :saldo_anterior, :decimal, precision: 10, scale: 2
  end
end
