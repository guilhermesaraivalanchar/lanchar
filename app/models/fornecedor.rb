class Fornecedor < ApplicationRecord
  belongs_to :escola
  has_many :entrada_produtos, :dependent => :destroy
end
