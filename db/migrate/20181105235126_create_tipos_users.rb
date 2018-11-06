class CreateTiposUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :tipos_users do |t|
      t.integer :user_id
      t.integer :tipo_user_id

      t.timestamps
    end
  end
end
