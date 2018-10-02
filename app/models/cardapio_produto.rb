class CardapioProduto < ApplicationRecord
  belongs_to :cardapio
  belongs_to :produto
  validates_presence_of :produto_id
  validates_presence_of :preco
end
