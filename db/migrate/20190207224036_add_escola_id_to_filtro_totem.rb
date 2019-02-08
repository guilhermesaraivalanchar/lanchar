class AddEscolaIdToFiltroTotem < ActiveRecord::Migration[5.2]
  def change
    add_reference :filtro_totens, :escola, index: true    
  end
end
