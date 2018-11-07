class AddTiposToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :tipos, :string
  end
end
