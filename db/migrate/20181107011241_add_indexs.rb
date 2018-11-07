class AddIndexs < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :codigo
    add_index :transferencias, :produto_id
    add_index :transferencias, :combo_id

    add_index :bloqueio_produtos, :user_id
    add_index :bloqueio_produtos, :produto_id
    add_index :permissoes, :permissao_codigo
    add_index :permissoes_users, :permissao_id
    add_index :permissoes_users, :user_id
    add_index :permissoes_users, :tipo_user_id
    add_index :responsavel_users, :responsavel_id
    add_index :responsavel_users, :user_id
    add_index :tipos_users, :tipo_user_id
    add_index :tipos_users, :user_id

  end
end
