class FiltroTotemProduto < ApplicationRecord
	belongs_to :produto
	belongs_to :filtro_totem
end
