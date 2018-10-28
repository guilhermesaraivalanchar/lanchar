class AddUserIdToEntrada < ActiveRecord::Migration[5.2]
  def change
    add_reference :entrada_produtos, :user, index: true
  end
end
