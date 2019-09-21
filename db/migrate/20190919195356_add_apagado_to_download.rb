class AddApagadoToDownload < ActiveRecord::Migration[5.2]
  def change
    add_column :downloads, :apagado, :boolean
  end
end
