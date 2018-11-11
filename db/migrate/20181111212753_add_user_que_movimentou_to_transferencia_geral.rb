class AddUserQueMovimentouToTransferenciaGeral < ActiveRecord::Migration[5.2]
  def change
    add_column :transferencia_gerais, :user_movimentou_id, :integer
  end
end
