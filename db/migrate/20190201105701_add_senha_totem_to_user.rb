class AddSenhaTotemToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :senha_totem, :string
  end
end
