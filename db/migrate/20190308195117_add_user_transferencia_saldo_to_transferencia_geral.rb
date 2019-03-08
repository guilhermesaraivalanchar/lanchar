class AddUserTransferenciaSaldoToTransferenciaGeral < ActiveRecord::Migration[5.2]
  def change
    add_column :transferencia_gerais, :user_transferencia_saldo, :integer
  end
end
