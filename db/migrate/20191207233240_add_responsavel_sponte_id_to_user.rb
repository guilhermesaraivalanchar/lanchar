class AddResponsavelSponteIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :responsavel_sponte_id, :string
  end
end
