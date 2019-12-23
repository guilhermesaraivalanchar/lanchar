class AddAlunoidToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :aluno_id_sponte, :string
  end
end
