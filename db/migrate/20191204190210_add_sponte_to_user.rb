class AddSponteToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :sponte, :boolean
  end
end
