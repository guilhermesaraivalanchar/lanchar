class AddNomeToDownload < ActiveRecord::Migration[5.2]
  def change
    add_column :downloads, :nome, :string
  end
end
