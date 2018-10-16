class FixEscolaIdUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :escola_id
    add_column :users, :escola_id, :integer
  end
end
