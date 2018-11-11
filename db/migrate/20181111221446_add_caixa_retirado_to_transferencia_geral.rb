class AddCaixaRetiradoToTransferenciaGeral < ActiveRecord::Migration[5.2]
  def change
    add_column :transferencia_gerais, :user_caixa_id, :integer
    add_column :transferencias, :user_caixa_id, :integer
  end
end
