class Permissao < ApplicationRecord
	has_many :permissoes_users, :dependent => :destroy
  	validates_uniqueness_of :permissao_codigo
end
