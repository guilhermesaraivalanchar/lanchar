class AddTipoToTransferencias < ActiveRecord::Migration[5.2]
  def change
    add_column :transferencia_gerais, :tipo, :string
    add_column :transferencias, :tipo, :string
  end
end
