class AddNomeToEquipamento < ActiveRecord::Migration[5.2]
  def change
    add_column :equipamentos, :nome, :string
    add_reference :equipamentos, :escola, index: true    
  end
end
