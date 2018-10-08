class CreatePermissoesUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :permissoes_users do |t|
      t.integer :tipo_user_id
      t.integer :user_id
      t.integer :permissao_id
      
      t.timestamps
    end
  end
end
