class AddCanceladasToTransferenciaGeral < ActiveRecord::Migration[5.2]
  def change
    add_column :transferencia_gerais, :data_cancelada, :datetime
    add_reference :transferencia_gerais, :user_cancelou, index: true
  end
end
