class ComboTipoProduto < ApplicationRecord
	belongs_to :tipo_produto
	belongs_to :combo
end
