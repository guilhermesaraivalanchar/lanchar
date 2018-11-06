class RemoveTipoUserToUser < ActiveRecord::Migration[5.2]
  def change
  	remove_column :users, :tipo_user_id
  end
end
