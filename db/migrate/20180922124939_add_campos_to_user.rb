class AddCamposToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :codigo, :string
    add_column :users, :desconto_id, :string
    add_column :users, :tipo_id, :string
    add_column :users, :cartao_id, :string
  end
end
