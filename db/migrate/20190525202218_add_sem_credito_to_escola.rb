class AddSemCreditoToEscola < ActiveRecord::Migration[5.2]
  def change
    add_column :escolas, :sem_credito, :boolean
  end
end
