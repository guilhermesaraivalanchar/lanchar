class AddTipoCreditoToTransferenciaGeral < ActiveRecord::Migration[5.2]
  def change
    add_reference :transferencia_gerais, :tipo_credito, index: true
  end
end
