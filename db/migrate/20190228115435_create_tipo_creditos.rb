class CreateTipoCreditos < ActiveRecord::Migration[5.2]
  def change
    create_table :tipo_creditos do |t|
      t.integer :escola_id
      t.string :tipo

      t.timestamps
    end
  end
end
