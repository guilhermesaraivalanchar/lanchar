class TipoProduto < ApplicationRecord
	belongs_to :escola
	has_many :produtos
	has_many :combo_tipo_produtos
end
