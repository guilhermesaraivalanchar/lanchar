class AddDemandaEntradaToEntradaProduto < ActiveRecord::Migration[5.2]
  def change
    add_reference :entrada_produtos, :demanda_entrada, index: true
  end
end
