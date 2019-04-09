class CreateLogCaixas < ActiveRecord::Migration[5.2]
  def change
    create_table :log_caixas do |t|
      t.references :transferencia_geral, index: true
      t.decimal :valor, precision: 10, scale: 2
      t.references :caixa, index: true

      t.timestamps
    end
  end
end
