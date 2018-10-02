class TipoUser < ApplicationRecord
  has_many :users

  validates_presence_of :nome
end
