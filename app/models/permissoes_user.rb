class PermissoesUser < ApplicationRecord
	belongs_to :tipo_user
	belongs_to :permissao
end
