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

  has_attached_file :imagem, :styles => { :original => "400x400>" }
  do_not_validate_attachment_file_type :imagem
  #validates_attachment_presence :imagem, :message => "É necessário enviar a placa do veículo"
  #validates_attachment_content_type :imagem, :message => "O arquivo enviado não é uma imagem", :content_type => %w( image/jpeg image/png image/gif image/pjpeg image/x-png )

  validate :tipo_foto
  
  def tipo_foto

    if imagem_content_type && imagem_content_type != "image/jpg" && imagem_content_type != "image/jpeg" && imagem_content_type != "image/png"
      errors.add("Foto ", "deve ser uma imagem no formato PNG, JPG ou JPEG.")
    end
  end

  def tem_permissao(perm_codigo)
    return true if self.admin
    self.tipo_user.tem_permissao(perm_codigo)
  end
end
