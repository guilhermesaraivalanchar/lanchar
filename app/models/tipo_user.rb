class TipoUser < ApplicationRecord
  belongs_to :escola
  has_many :permissoes_users
  has_many :tipos_users
  has_many :users, :through => :tipos_users

  attr_accessor :permissao_ids
  attr_accessor :from_form

  validates_presence_of :nome

  after_save :att_permissoes, if: -> { self.from_form }

  def att_permissoes

    self.permissoes_users.destroy_all

    if permissao_ids
    	self.permissao_ids.each do |permissao_id|
        per = PermissoesUser.create(tipo_user_id: self.id, permissao_id: permissao_id.to_i)
      end
    end

    self.att_comprar_users
  end


  def tem_permissao(perm_codigo)
    self.permissoes_users.joins("INNER JOIN permissoes on permissoes.id = permissoes_users.permissao_id").where("permissoes.permissao_codigo = '#{perm_codigo}'").last.present?
  end

  def att_comprar_users
    TipoUser.delay.att_comprar_users_delay(self.id)
  end

  def self.att_comprar_users_delay(tipo_user_id)
    tipo = TipoUser.find(tipo_user_id)
    pode_comprar = tipo.tem_permissao("user_comprar")
    if pode_comprar
      tipo.users.update_all(sem_compra: false)
    else
      tipo.users.each do |user|
        user.update_attribute(:sem_compra, false) if user.tem_permissao("user_comprar")
        user.update_attribute(:sem_compra, true) if !user.tem_permissao("user_comprar")
      end
    end
  end
end
