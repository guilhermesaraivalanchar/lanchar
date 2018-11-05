class TipoUser < ApplicationRecord
  belongs_to :escola
  has_many :users
  has_many :permissoes_users

  attr_accessor :permissao_ids

  validates_presence_of :nome

  after_save :att_permissoes

  def att_permissoes

    self.permissoes_users.destroy_all

    if permissao_ids
    	self.permissao_ids.each do |permissao_id|
        per = PermissoesUser.create(tipo_user_id: self.id, permissao_id: permissao_id.to_i)
        if per
          puts " CRIO"

        else
          puts "nao"
          puts per.errors.inspect

        end
      end
    end
  end


  def tem_permissao(perm_codigo)
    self.permissoes_users.joins("INNER JOIN permissoes on permissoes.id = permissoes_users.permissao_id").where("permissoes.permissao_codigo = '#{perm_codigo}'").last.present?
  end
end
