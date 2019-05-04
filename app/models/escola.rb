class Escola < ApplicationRecord
  
  has_many :users, :dependent => :destroy
  has_many :produtos, :dependent => :destroy
  has_many :combos, :dependent => :destroy
  has_many :transferencia_gerais, :dependent => :destroy
  has_many :transferencias, :dependent => :destroy
  has_many :cardapios, :dependent => :destroy
  has_many :tipo_produtos, :dependent => :destroy
  has_many :tipo_users, :dependent => :destroy
  has_many :fornecedores, :dependent => :destroy
  has_many :equipamentos, :dependent => :destroy

  has_attached_file :logo, :styles => { :original => "900x900>" }
    do_not_validate_attachment_file_type :logo

  def saldo_devedor
    valor_vendido = self.transferencias.where("transferencias.valor > 0").where(tipo: ["VENDA", "VENDA_DIRETA"]).sum(:valor).to_d
    valor_reembolso = self.transferencias.where("transferencias.valor > 0").where(tipo: ["REEMBOLSO"]).sum(:valor).to_d
    valor = valor_vendido - valor_reembolso
    return valor * 0.02
  end

  def faturamento_diario
    self.transferencia_gerais.where("transferencia_gerais.created_at > ? AND transferencia_gerais.created_at < ? AND transferencia_gerais.valor > 0", Time.now.beginning_of_day, Time.now.end_of_day).where(cancelada: [nil, false], tipo: ["VENDA", "VENDA_DIRETA"]).sum(:valor)
  end

  def faturamento_mensal
    self.transferencia_gerais.where("transferencia_gerais.created_at > ? AND transferencia_gerais.created_at < ? AND transferencia_gerais.valor > 0" , Time.now.beginning_of_month, Time.now.end_of_month).where(cancelada: [nil, false], tipo: ["VENDA", "VENDA_DIRETA"]).sum(:valor)
  end

  def saldo_em_caixa
    self.transferencias.where(tipo: ['ENTRADA','SAIDA','VENDA_DIRETA','SAIDA CANCELADA','DEPOSITO CANCELADO','REEMBOLSO_VENDA_DIRETA']).sum(&:valor)
  end

  def self.criar_escola(nome)
    escola = Escola.new(nome: nome)

    escola.tipo_users.new(nome: "Administrador", codigo: "admin")
    escola.tipo_users.new(nome: "Aluno", codigo: "aluno")
    escola.tipo_users.new(nome: "Responsável", codigo: "responsavel")


    #User.create(nome:"SISTEMA", email:"sistema1@sistemacantinapro.com.br", escola_id: 1, codigo:"SISTEMA_____1", password:123456, sistema: true)
  end
end
