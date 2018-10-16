class AddEscolaIdToTables < ActiveRecord::Migration[5.2]
  def change
    
  	#Add Colum
    add_column :transferencia_gerais, :escola_id, :integer
    add_column :transferencias, :escola_id, :integer
    add_column :cardapios, :escola_id, :integer
    add_column :combos, :escola_id, :integer
    add_column :tipo_produtos, :escola_id, :integer
    add_column :tipo_users, :escola_id, :integer

    # Add Indexs
    add_index :transferencia_gerais, :escola_id
    add_index :transferencias, :escola_id
    add_index :cardapios, :escola_id
    add_index :combos, :escola_id
    add_index :tipo_produtos, :escola_id
    add_index :tipo_users, :escola_id
    add_index :produtos, :escola_id

    #Add Outros Indexs
    add_index :transferencia_gerais, :user_id
    add_index :transferencias, :transferencia_geral_id
    add_index :transferencia_combos, :transferencia_id

  end
end
