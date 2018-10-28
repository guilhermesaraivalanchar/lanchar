class AddTurmaToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :turma, :string
  end
end
