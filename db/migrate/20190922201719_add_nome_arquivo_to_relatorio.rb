class AddNomeArquivoToRelatorio < ActiveRecord::Migration[5.2]
  def change
    add_column :relatorios, :nome_arquivo, :string
  end
end
