class CreateFiltroTotens < ActiveRecord::Migration[5.2]
  def change
    create_table :filtro_totens do |t|
      t.string :nome

      t.timestamps
    end
  end
end
