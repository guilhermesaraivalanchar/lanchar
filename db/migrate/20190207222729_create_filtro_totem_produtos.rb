class CreateFiltroTotemProdutos < ActiveRecord::Migration[5.2]
  def change
    create_table :filtro_totem_produtos do |t|
      t.references :produto, :index => true
      t.references :filtro_totem, :index => true
      t.timestamps
    end
  end
end
