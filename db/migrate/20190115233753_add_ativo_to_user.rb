class AddAtivoToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :ativo, :boolean
  end
end
