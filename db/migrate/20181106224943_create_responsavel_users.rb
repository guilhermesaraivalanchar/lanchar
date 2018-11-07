class CreateResponsavelUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :responsavel_users do |t|
      t.integer :responsavel_id
      t.integer :user_id

      t.timestamps
    end
  end
end
