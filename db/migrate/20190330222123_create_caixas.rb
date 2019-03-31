class CreateCaixas < ActiveRecord::Migration[5.2]
  def change
    create_table :caixas do |t|
    	t.references :user, index: true
      t.decimal :valor, precision: 10, scale: 2

      t.timestamps
    end
  end
end
