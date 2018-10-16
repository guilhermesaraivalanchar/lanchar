class Escola < ApplicationRecord
	
	has_many :users
	has_many :produtos
	has_many :combos
	has_many :transferencia_gerais
	has_many :transferencias
	has_many :cardapios
	has_many :tipo_produtos
	has_many :tipo_users
	has_many :fornecedores

end
