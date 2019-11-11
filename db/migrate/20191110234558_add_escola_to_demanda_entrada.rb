class AddEscolaToDemandaEntrada < ActiveRecord::Migration[5.2]
  def change
    add_reference :demanda_entradas, :escola, index: true
  end
end
