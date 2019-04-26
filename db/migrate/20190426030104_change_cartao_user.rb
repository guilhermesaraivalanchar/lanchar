class ChangeCartaoUser < ActiveRecord::Migration[5.2]
  def change
  	remove_column :users, :cartao_id
  	add_column :users, :cartao, :string
  end
end
