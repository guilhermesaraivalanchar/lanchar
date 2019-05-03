class AddItensSeparadosToEscola < ActiveRecord::Migration[5.2]
  def change
    add_column :escolas, :itens_separados, :boolean
  end
end
