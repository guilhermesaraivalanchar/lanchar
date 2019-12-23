class AddDefToTipoUser < ActiveRecord::Migration[5.2]
  def change
    add_column :tipo_users, :aluno, :boolean
    add_column :tipo_users, :responsavel, :boolean
    add_column :tipo_users, :admin, :boolean
    add_column :tipo_users, :protegido, :boolean
  end
end
