class TipoProduto < ApplicationRecord
	has_many :produtos
	has_many :combo_tipo_produtos
end
