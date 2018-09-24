class Produto < ApplicationRecord
  include AASM

  has_attached_file :imagem
  do_not_validate_attachment_file_type :imagem
  #validates_attachment_presence :imagem, :message => "É necessário enviar a placa do veículo"
  #validates_attachment_content_type :imagem, :message => "O arquivo enviado não é uma imagem", :content_type => %w( image/jpeg image/png image/gif image/pjpeg image/x-png )

  validate :tipo_foto
  
  #Configuração da State Machine
  aasm column: "status" do
    state :ativo, :initial => true
    state :desativado
  end

  def tipo_foto
    
    if imagem_content_type && imagem_content_type != "image/jpg" && imagem_content_type != "image/jpeg" && imagem_content_type != "image/png"
      errors.add("Foto ", "deve ser uma imagem no formato PNG, JPG ou JPEG.")
    end
  end


end
