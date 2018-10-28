class VerProdPerm < ActiveRecord::Migration[5.2]
  def change
  	Permissao.create(permissao_nome: "Ver Entrada Produto (Sistema)", permissao_codigo: "ver_entrada_produto", permissao_grupo: "Entrada Produto")
  end
end
