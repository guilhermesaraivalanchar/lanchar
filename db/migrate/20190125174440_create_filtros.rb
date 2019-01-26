class CreateFiltros < ActiveRecord::Migration[5.2]
  def change
    create_table :filtros do |t|
      t.string :local
      t.string :filtro_1
      t.string :filtro_2
      t.string :filtro_3
      t.string :filtro_4
      t.string :filtro_5
      t.string :filtro_6
      t.string :filtro_7
      t.string :filtro_8
      t.string :filtro_9
      t.string :filtro_10
      t.string :visiveis
			t.references :user, :index => true

      t.timestamps
    end
  end
end
