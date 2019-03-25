class AddPermConfTransf < ActiveRecord::Migration[5.2]
  def change
  	# Configuração Pais
	Permissao.create(permissao_nome: "Transferência de Saldo", permissao_codigo: "transferencia_de_saldo", permissao_grupo: "Sistema")
	Permissao.create(permissao_nome: "Transferência de Saldo", permissao_codigo: "transferencia_de_saldo_pais", permissao_grupo: "Configuração Pais")
  end
end
