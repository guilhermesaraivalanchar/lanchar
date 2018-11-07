class RemoveResponsavelId < ActiveRecord::Migration[5.2]
  def change
  	remove_column :users, :usuario_responsavel_id
  end
end
