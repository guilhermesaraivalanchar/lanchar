class AddEscolaToRelatorio < ActiveRecord::Migration[5.2]
  def change
    add_reference :relatorios, :escola, index: true
  end
end
