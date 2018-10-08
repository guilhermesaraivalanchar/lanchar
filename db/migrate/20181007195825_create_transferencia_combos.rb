class CreateTransferenciaCombos < ActiveRecord::Migration[5.2]
  def change
    create_table :transferencia_combos do |t|
      t.integer :transferencia_id
      t.integer :combo_id

      t.timestamps
    end
  end
end
