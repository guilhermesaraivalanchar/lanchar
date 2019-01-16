class FixAtivos < ActiveRecord::Migration[5.2]
  def change
	  User.all.update_all(ativo: true)
	  Produto.all.update_all(ativo: true)
  end
end
