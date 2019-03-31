class Caixa < ApplicationRecord
  belongs_to :user
  has_many :caixa_historicos
end
