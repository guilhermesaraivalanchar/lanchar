class AddCreditoToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :credito, :integer
  end
end
