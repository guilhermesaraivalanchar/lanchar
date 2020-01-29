class AddDefToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :responsavel, :boolean
    add_column :users, :aluno, :boolean
  end
end
