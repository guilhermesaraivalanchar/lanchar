class CreateRelatorios < ActiveRecord::Migration[5.2]
  def change
    create_table :relatorios do |t|
      t.string :nome
      t.references :user, index: true

      t.timestamps
    end
  end
end
