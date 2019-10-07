class Equipamento < ApplicationRecord

  belongs_to :escola
  has_many :transferencia_gerais
  has_many :transferencias
  before_create :generate_token

protected

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Equipamento.exists?(token: random_token)
    end
  end

end
