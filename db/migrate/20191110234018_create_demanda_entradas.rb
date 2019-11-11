class CreateDemandaEntradas < ActiveRecord::Migration[5.2]
  def change
    create_table :demanda_entradas do |t|

      t.timestamps
    end
  end
end
