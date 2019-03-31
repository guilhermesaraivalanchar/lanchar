class CreateCaixaHistoricos < ActiveRecord::Migration[5.2]
  def change
    create_table :caixa_historicos do |t|
      t.references :caixa, index: true
      t.references :user, index: true
      t.decimal :valor, precision: 10, scale: 2
      t.integer :tipo

      t.timestamps
    end
  end
end
