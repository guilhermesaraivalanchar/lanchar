class AddIgSaldoToTransferenciaGeral < ActiveRecord::Migration[5.2]
  def change
    add_column :transferencia_gerais, :ig_saldo, :boolean
  end
end
