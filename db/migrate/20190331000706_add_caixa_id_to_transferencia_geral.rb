class AddCaixaIdToTransferenciaGeral < ActiveRecord::Migration[5.2]
  def change
    add_reference :transferencia_gerais, :caixa, index: true
  end
end
