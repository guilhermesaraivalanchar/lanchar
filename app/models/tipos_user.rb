class TiposUser < ApplicationRecord
	belongs_to :user
	belongs_to :tipo_user
end
