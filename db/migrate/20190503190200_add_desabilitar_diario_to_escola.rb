class AddDesabilitarDiarioToEscola < ActiveRecord::Migration[5.2]
  def change
    add_column :escolas, :desabilitar_diario, :boolean
  end
end
