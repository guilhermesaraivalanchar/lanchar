class TiposUser < ApplicationRecord
  belongs_to :user
  belongs_to :tipo_user

  after_save :set_usuario

  def set_usuario
    self.user.update_attribute(:responsavel, true) if self.tipo_user.responsavel
    self.user.update_attribute(:aluno, true) if self.tipo_user.aluno
  end
end
