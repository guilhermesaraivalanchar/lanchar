class AddSistemaToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sistema, :boolean
  end
end
