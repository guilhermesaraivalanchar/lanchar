class AddBloqueadoToTipoUser < ActiveRecord::Migration[5.2]
  def change
    add_column :tipo_users, :bloqueado, :boolean
  end
end
