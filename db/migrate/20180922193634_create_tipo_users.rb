class CreateTipoUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :tipo_users do |t|
      t.string :nome
      t.integer :desconto_id

      t.timestamps
    end
  end
end
