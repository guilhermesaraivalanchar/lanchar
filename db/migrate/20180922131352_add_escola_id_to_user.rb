class AddEscolaIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :escola_id, :string
  end
end
