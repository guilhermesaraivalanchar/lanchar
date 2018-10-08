class AddUserResponsavelIdToUser < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :usuario_responsavel_id, :integer
  end
end
