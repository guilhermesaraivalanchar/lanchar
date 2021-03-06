class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable

  belongs_to :escola

  validates_presence_of :nome
  validates_presence_of :codigo
  #validates_uniqueness_of :codigo

  #validates :codigo, uniqueness: true
  validates :codigo, uniqueness: { scope: :escola_id, message: 'Já existe um usuário com este codigo.'  }

  has_many :responsavel_users, :dependent => :destroy 
  has_many :transferencia_gerais, :dependent => :destroy
  has_many :entrada_produtos
  has_many :bloqueio_produtos, :dependent => :destroy
  has_many :caixa_historicos
  has_one :caixa
  has_many :tipos_users
  has_many :downloads
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

  before_save :check_credito
  after_save :salvar_responsavel, :if => :enable_after_save
  before_save :atualizar_responsaveis_ativos
  after_save :att_bloqueio_produto, :salvar_tipo_users, :if => :enable_after_save

  def self.teste_work(valor)
    #TesteWorker.perform_async(valor)
    TesteWorker.perform_in(1.minutes, valor)
  end

  def check_credito
    self.credito = 0 if !self.credito
    #self.saldo = 0 if !self.saldo
  end

  def dependentes
    return User.where(id: ResponsavelUser.where(responsavel_id: self.id ).map(&:user_id))
  end

  def delete_relacao_dependentes
    ResponsavelUser.where(responsavel_id: self.id).destroy_all
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
      end
    end

    self.update_column(:bloq_produto, self.bloqueio_produtos.map(&:produto_id).join(',').to_s)

    # User.all.each do |u|
    #   u.update_column(:bloq_produto, u.bloqueio_produtos.map(&:produto_id).join(',').to_s)
    # end
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

  def user_tipo(tipo)
    return self.tipos_users.map(&:tipo_user).map(&:codigo).include?(tipo)
  end

  def saldo_diario_atual
    
    return (self.saldo.to_d + self.credito.to_d) if !self.saldo_diario || self.escola.desabilitar_diario

    #return (self.saldo_diario - self.saldo_gasto_hoje.to_d) 

    saldo_max = (self.saldo.to_d + self.credito.to_d)

    saldo_possivel = (self.saldo_diario < saldo_max) ? self.saldo_diario : saldo_max

    return (saldo_possivel - self.saldo_gasto_hoje.to_d)

  end

  def saldo_gasto_hoje
    transferencia_gerais.where("transferencia_gerais.created_at > ? AND transferencia_gerais.created_at < ? AND transferencia_gerais.valor > 0", Time.now.beginning_of_day, Time.now.end_of_day).where(cancelada: [nil, false], tipo: ["VENDA", "VENDA_DIRETA"]).sum(:valor)
  end

  def url
    return "/imagens/user.jpg" if self.imagem.url == "/imagens/original/missing.png"
    return self.imagem.url
  end

  def atualizar_responsaveis_ativos
    if self.ativo_changed?
      if self.ativo
        self.responsavel_users.map(&:responsavel_id).each do |responsavel_id|
          responsavel = User.find(responsavel_id)
          responsavel.update_attribute(:ativo, true) if responsavel
        end
      else
        self.responsavel_users.map(&:responsavel_id).each do |responsavel_id|
          responsavel = User.find(responsavel_id)
          flag_ainda_ativo = ResponsavelUser.where(responsavel_id: responsavel_id).map(&:user).map(&:ativo).include?(true)
          responsavel.update_attribute(:ativo, false) if responsavel && !flag_ainda_ativo
        end
      end
    end
  end
end
