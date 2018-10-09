class TransferenciaGeral < ApplicationRecord
	belongs_to :user
	has_many :transferencias, :dependent => :destroy
end
