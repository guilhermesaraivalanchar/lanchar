class CreateTransferenciaGerais < ActiveRecord::Migration[5.2]
  def change
    create_table :transferencia_gerais do |t|
      t.integer :user_id
      t.float :valor

      t.timestamps
    end
  end
end
