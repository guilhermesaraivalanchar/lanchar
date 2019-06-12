class AddEsolaIdToCaixa < ActiveRecord::Migration[5.2]
  def change
    add_reference :caixas, :escola, index: true
  end
end
