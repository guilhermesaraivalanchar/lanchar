class CreateFornecedores < ActiveRecord::Migration[5.2]
  def change
    create_table :fornecedores do |t|
      t.integer :codigo
      t.string :nome
      t.string :contato
      t.string :email
      t.string :telefone

      t.timestamps
    end
  end
end
