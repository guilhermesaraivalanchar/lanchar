class CreateTransferencias < ActiveRecord::Migration[5.2]
  def change
    create_table :transferencias do |t|
      t.integer :user_movimentou_id
      t.integer :user_id
      t.integer :produto_id
      t.integer :combo_id

      t.timestamps
    end
  end
end
