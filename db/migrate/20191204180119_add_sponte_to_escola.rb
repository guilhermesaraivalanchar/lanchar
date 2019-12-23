class AddSponteToEscola < ActiveRecord::Migration[5.2]
  def change
    add_column :escolas, :token_sponte, :string
    add_column :escolas, :cliente_sponte, :string
  end
end
