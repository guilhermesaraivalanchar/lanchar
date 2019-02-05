class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable

  belongs_to :escola

  validates_presence_of :nome
  validates_presence_of :codigo
  validates_uniqueness_of :codigo

  validates :codigo, uniqueness: true

  has_many :responsavel_users, :dependent => :destroy 
  has_many :transferencia_gerais, :dependent => :destroy
  has_many :entrada_produtos
  has_many :bloqueio_produtos, :dependent => :destroy
  has_many :tipos_users
  has_attached_file :imagem, :styles => { :original => "400x400>" }
  do_not_validate_attachment_file_type :imagem
  #validates_attachment_presence :imagem, :message => "É necessário enviar a placa do veículo"
  #validates_attachment_content_type :imagem, :message => "O arquivo enviado não é uma imagem", :content_type => %w( image/jpeg image/png image/gif image/pjpeg image/x-png )

  before_destroy :delete_relacao_dependentes

  validate :tipo_foto

  attr_accessor :produto_ids
  attr_accessor :tipo_users
  attr_accessor :responsavel_ids
  attr_accessor :enable_after_save

  after_save :salvar_responsavel, :if => :enable_after_save

  after_save :att_bloqueio_produto, :salvar_tipo_users, :if => :enable_after_save

  def delete_relacao_dependentes
    if self.sem_compra
      ResponsavelUser.where(responsavel_id: self.id).destroy_all
    end
  end

  def salvar_responsavel
    if responsavel_ids
      self.responsavel_users.destroy_all
      self.responsavel_ids.split(",").each do |responsavel_id|
        ResponsavelUser.create(user_id: self.id, responsavel_id: responsavel_id)
      end
    end
  end

  def att_bloqueio_produto
    self.bloqueio_produtos.destroy_all
    if produto_ids
      self.produto_ids.each do |produto_id|
        per = BloqueioProduto.create(user_id: self.id, produto_id: produto_id.to_i)
        if per
          puts " CRIO"

        else
          puts "nao"
          puts per.errors.inspect

        end
      end
    end
  end

  def salvar_tipo_users
    if tipo_users
      tipos_ids = []
      self.tipos_users.destroy_all
      self.tipo_users.split(",").each do |tipo_user_id|
        TiposUser.create(user_id: self.id, tipo_user_id: tipo_user_id)
        tipos_ids << tipo_user_id.to_i
      end
      self.enable_after_save = false
      self.update_attribute(:tipos, (TipoUser.where(id: tipos_ids).map(&:nome).join(', ') rescue "") )
    end
  end

  def tipo_foto

    if imagem_content_type && imagem_content_type != "image/jpg" && imagem_content_type != "image/jpeg" && imagem_content_type != "image/png"
      errors.add("Foto ", "deve ser uma imagem no formato PNG, JPG ou JPEG.")
    end
  end

  def tem_permissao(perm_codigo)
    
    return true if self.admin

    self.tipos_users.each do |tipos_userr|
      return true if tipos_userr.tipo_user.tem_permissao(perm_codigo)
    end

    return false
  end

  def check_perms(perms)

    return true if self.admin

    perms.each do |perm|
      self.tipos_users.each do |tipos_userr|
        return true if tipos_userr.tipo_user.tem_permissao(perm)
      end
    end
    
    return false
  end

  def user_responsavel(user)
  end

  def saldo_diario_atual
    
    return (self.saldo.to_d + self.credito.to_d) if !self.saldo_diario

    #return (self.saldo_diario - self.saldo_gasto_hoje.to_d) 

    saldo_max = (self.saldo.to_d + self.credito.to_d)

    saldo_possivel = (self.saldo_diario < saldo_max) ? self.saldo_diario : saldo_max

    return (saldo_possivel - self.saldo_gasto_hoje.to_d)

  end

  def saldo_gasto_hoje
    transferencia_gerais.where("transferencia_gerais.created_at > ? AND transferencia_gerais.created_at < ? AND transferencia_gerais.valor > 0", Time.now.beginning_of_day, Time.now.end_of_day).where(cancelada: [nil, false], tipo: ["VENDA", "VENDA_DIRETA"]).sum(:valor)
  end
end
