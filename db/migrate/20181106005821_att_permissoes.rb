class AttPermissoes < ActiveRecord::Migration[5.2]
  def change
  	Permissao.where(permissao_codigo: "auto_creditar").last.destroy
  	Permissao.where(permissao_codigo: "creditar_usuarios_dependentes").last.destroy
  	Permissao.where(permissao_codigo: "limite_credito").last.destroy
  	Permissao.where(permissao_codigo: "editar_saldo_diario").last.destroy

  	Permissao.create(permissao_nome: "Resetar Senha", permissao_codigo: "resetar_senha_usuario", permissao_grupo: "Usuários")
	Permissao.create(permissao_nome: "Bloquear Produtos", permissao_codigo: "bloquear_produtos", permissao_grupo: "Usuários")
	Permissao.create(permissao_nome: "Editar Funções Credito", permissao_codigo: "editar_funcoes_credito", permissao_grupo: "Usuários")
  end
end
