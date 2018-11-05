class AddSaldoDiarioToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :saldo_diario, :decimal, precision: 10, scale: 2
  end
end
