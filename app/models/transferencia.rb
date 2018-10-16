class Transferencia < ApplicationRecord
	belongs_to :escola
	belongs_to :transferencia_geral
	belongs_to :produto, optional: true
	belongs_to :combo, optional: true
	has_many :transferencia_combos, :dependent => :destroy
end
