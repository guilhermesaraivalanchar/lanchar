class EntradaProduto < ApplicationRecord
  belongs_to :fornecedor, optional: true
  belongs_to :produto
  belongs_to :user
  belongs_to :demanda_entrada

  after_save :att_produtos

  def att_produtos
    if self.tipo == "ENTRADA"
      self.produto.update_attribute(:quantidade, self.produto.quantidade + self.quantidade)
    else
      self.produto.update_attribute(:quantidade, self.produto.quantidade - self.quantidade)
    end
  end
end
