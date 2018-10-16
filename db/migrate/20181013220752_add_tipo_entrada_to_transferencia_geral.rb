class AddTipoEntradaToTransferenciaGeral < ActiveRecord::Migration[5.2]
  def change
    add_column :transferencia_gerais, :tipo_entrada, :string
  end
end
