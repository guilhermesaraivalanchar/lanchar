class CardapioCombo < ApplicationRecord
	belongs_to :combo
	belongs_to :cardapio
  	validates_presence_of :combo_id
  	validates_presence_of :preco
end
