class Produto < ApplicationRecord
  include AASM

  belongs_to :escola
  belongs_to :tipo_produto
  has_many :cardapio_produtos, :dependent => :destroy
  has_many :combo_produtos, :dependent => :destroy
  has_many :entrada_produtos, :dependent => :destroy
  has_many :transferencias, :dependent => :destroy
  has_many :transferencia_combos, :dependent => :destroy
  has_many :bloqueio_produtos, :dependent => :destroy
  has_many :filtro_totem_produtos, :dependent => :destroy
  has_attached_file :imagem, :styles => { :original => "400x400>"}
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

  def self.get_prod_vendidos(quantidade)

    sql = %Q{
      SELECT produto_transf.nome as produto_transf_nome, produto_combo_transf.nome as produto_combo_transf_nome
      FROM transferencias 
      LEFT JOIN transferencia_combos ON transferencia_combos.transferencia_id = transferencias.id
      LEFT JOIN produtos AS produto_transf ON produto_transf.id = transferencias.produto_id
      LEFT JOIN produtos AS produto_combo_transf ON produto_combo_transf.id = transferencia_combos.produto_id
      WHERE (transferencias.tipo = 'VENDA' OR transferencias.tipo = 'VENDA_DIRETA') 
      AND transferencias.cancelada IS NULL
      AND transferencias.created_at > ? AND transferencias.created_at < ?

    }

    sql = %Q{
        SELECT    strftime('%Y', created_at) AS "Year",
                  strftime('%m', created_at) AS "Month",
                  strftime('%d', created_at) AS "Day",
                  COUNT(*) AS "transf",
                  SUM(transferencias.valor) AS "valor",
                  tipo,
                  cancelada
        FROM      transferencias
        WHERE transferencias.created_at > '#{data_inicio}'
        AND transferencias.created_at < '#{data_fim}'
        AND transferencias.escola_id = '#{current_user.escola_id}'
        GROUP BY  strftime('%d', created_at),
                  strftime('%m', created_at),
                  strftime('%Y', created_at),
                  tipo,
                  cancelada
        ORDER BY  "Year",
                  "Month",
                  "Day"

    }



  end


end
