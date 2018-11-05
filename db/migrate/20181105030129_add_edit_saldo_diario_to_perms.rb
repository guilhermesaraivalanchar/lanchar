class AddEditSaldoDiarioToPerms < ActiveRecord::Migration[5.2]
  def change
   Permissao.create(permissao_nome: "Editar Saldo Diário", permissao_codigo: "editar_saldo_diario", permissao_grupo: "Usuários")
  end
end
