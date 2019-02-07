class AddCorFundoToEscola < ActiveRecord::Migration[5.2]
  def change
    add_column :escolas, :cor_fundo, :string
  end
end
