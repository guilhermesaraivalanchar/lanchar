class EntradaProduto < ApplicationRecord
  belongs_to :fornecedor, optional: true
  belongs_to :produto
  belongs_to :user
end
