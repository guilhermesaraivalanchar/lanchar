class AddDefToTipoCredito < ActiveRecord::Migration[5.2]
  def change
    add_column :tipo_creditos, :categoria_sponte, :string
    add_column :tipo_creditos, :forma_pagamento_sponte, :string
    add_column :tipo_creditos, :tipo_plano_sponte, :string
    add_column :tipo_creditos, :integracao_sponte, :boolean
  end
end
