class AddBloqueioCartaoToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :bloqueio_cartao, :boolean
    add_column :users, :cartao_sem_senha, :boolean
  end
end
