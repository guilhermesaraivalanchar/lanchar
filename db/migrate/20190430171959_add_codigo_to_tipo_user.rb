class AddCodigoToTipoUser < ActiveRecord::Migration[5.2]
  def change
    add_column :tipo_users, :codigo, :string
  end
end
