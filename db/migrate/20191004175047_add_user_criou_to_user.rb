class AddUserCriouToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :user_criou, :bigint
  end
end
