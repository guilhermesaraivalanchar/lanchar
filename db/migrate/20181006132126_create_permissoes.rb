class CreatePermissoes < ActiveRecord::Migration[5.2]
  def change
    create_table :permissoes do |t|
      t.string :permissao_nome
      t.string :permissao_codigo
      t.string :permissao_grupo

      t.timestamps
    end
  end
end
