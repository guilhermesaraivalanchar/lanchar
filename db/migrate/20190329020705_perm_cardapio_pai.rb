class PermCardapioPai < ActiveRecord::Migration[5.2]
  def change
	Permissao.create(permissao_nome: "Cardápio", permissao_codigo: "cardapio_pais", permissao_grupo: "Configuração Pais")
  end
end
