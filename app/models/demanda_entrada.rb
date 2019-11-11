class DemandaEntrada < ApplicationRecord
  has_many :entrada_produtos
  accepts_nested_attributes_for :entrada_produtos, reject_if: :all_blank, allow_destroy: true
end
