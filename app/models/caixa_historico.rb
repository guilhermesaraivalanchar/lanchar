class CaixaHistorico < ApplicationRecord
  belongs_to :caixa
  belongs_to :user
end
