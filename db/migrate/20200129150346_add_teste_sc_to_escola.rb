class AddTesteScToEscola < ActiveRecord::Migration[5.2]
  def change
    add_column :escolas, :teste_sc, :integer
  end
end
