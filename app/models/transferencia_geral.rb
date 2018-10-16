class TransferenciaGeral < ApplicationRecord
	
	belongs_to :escola
	belongs_to :user, optional: true
	has_many :transferencias, :dependent => :destroy
end
