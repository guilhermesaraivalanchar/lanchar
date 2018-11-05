class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable

  belongs_to :escola

  belongs_to :tipo_user, optional: true

  validates_presence_of :nome
  validates_presence_of :codigo

  validates :codigo, uniqueness: true

  has_many :transferencia_gerais, :dependent => :destroy
  has_many :entrada_produtos
  has_many :bloqueio_produtos, :dependent => :destroy

  has_attached_file :imagem, :styles => { :original => "400x400>" }
  do_not_validate_attachment_file_type :imagem
  #validates_attachment_presence :imagem, :message => "É necessário enviar a placa do veículo"
  #validates_attachment_content_type :imagem, :message => "O arquivo enviado não é uma imagem", :content_type => %w( image/jpeg image/png image/gif image/pjpeg image/x-png )

  validate :tipo_foto

  attr_accessor :produto_ids

  after_save :att_bloqueio_produto

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

  def tipo_foto

    if imagem_content_type && imagem_content_type != "image/jpg" && imagem_content_type != "image/jpeg" && imagem_content_type != "image/png"
      errors.add("Foto ", "deve ser uma imagem no formato PNG, JPG ou JPEG.")
    end
  end

  def tem_permissao(perm_codigo)
    return true if self.admin
    self.tipo_user.tem_permissao(perm_codigo)
  end

  def saldo_diario_atual
    
    return (self.saldo.to_d + self.credito.to_d) if !self.saldo_diario

    saldo_gasto_hoje = transferencia_gerais.where("transferencia_gerais.created_at > ? AND transferencia_gerais.created_at < ? AND transferencia_gerais.valor > 0", Time.now.beginning_of_day, Time.now.end_of_day).where(cancelada: [nil, false], tipo: ["VENDA", "VENDA_DIRETA"]).sum(:valor)
  
    return (self.saldo_diario - saldo_gasto_hoje.to_d) 
  end
end
