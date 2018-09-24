class AddSaldoToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :saldo, :decimal, precision: 10, scale: 2
  end
end
