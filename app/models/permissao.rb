class Permissao < ApplicationRecord
	has_many :permissoes_users, :dependent => :destroy
end
