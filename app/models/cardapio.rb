class Cardapio < ApplicationRecord
  
  has_many :cardapio_produtos
  has_many :cardapio_combos

  validates_presence_of :nome
  
  accepts_nested_attributes_for :cardapio_produtos, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :cardapio_combos, reject_if: :all_blank, allow_destroy: true

end
