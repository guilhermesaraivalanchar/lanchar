class AddIntegracaoDiariaSponteToEscola < ActiveRecord::Migration[5.2]
  def change
    add_column :escolas, :integracao_diaria_sponte, :boolean
  end
end
