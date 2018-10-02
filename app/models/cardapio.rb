class Cardapio < ApplicationRecord
  
  has_many :cardapio_produtos

  validates_presence_of :nome
  
  accepts_nested_attributes_for :cardapio_produtos, reject_if: :all_blank, allow_destroy: true

end
