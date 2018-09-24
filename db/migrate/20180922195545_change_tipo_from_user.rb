class ChangeTipoFromUser < ActiveRecord::Migration[5.2]
  def change
  	remove_column :users, :tipo_id
    add_column :users, :tipo_user_id, :string
  end
end
