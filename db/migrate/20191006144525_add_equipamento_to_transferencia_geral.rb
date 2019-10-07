class AddEquipamentoToTransferenciaGeral < ActiveRecord::Migration[5.2]
  def change
    add_reference :transferencia_gerais, :equipamento, index: true
  end
end
