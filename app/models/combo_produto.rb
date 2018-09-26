class ComboProduto < ApplicationRecord
	belongs_to :produto
	belongs_to :combo
end
