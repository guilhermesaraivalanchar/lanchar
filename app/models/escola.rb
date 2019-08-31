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
  has_many :tipo_creditos, :dependent => :destroy
  has_many :caixas, :dependent => :destroy

  has_attached_file :logo, :styles => { :original => "900x900>" }
    do_not_validate_attachment_file_type :logo

  def saldo_devedor
    valor_vendido = self.transferencias.where("transferencias.valor > 0").where(tipo: ["VENDA", "VENDA_DIRETA"]).sum(:valor).to_d
    valor_reembolso = self.transferencias.where("transferencias.valor > 0").where(tipo: ["REEMBOLSO"]).sum(:valor).to_d
    valor = valor_vendido - valor_reembolso
    return valor * 0.02
  end

  def faturamento_diario
    self.transferencias.where("transferencias.created_at > ? AND transferencias.created_at < ? AND transferencias.valor > 0", "#{Time.now.in_time_zone.strftime("%Y-%m-%d")} 00:00:00", "#{Time.now.in_time_zone.strftime("%Y-%m-%d")} 23:59:59").where(cancelada: [nil, false], tipo: ["VENDA", "VENDA_DIRETA"]).sum(:valor)
  end

  def faturamento_mensal
    self.transferencia_gerais.where("transferencia_gerais.created_at > ? AND transferencia_gerais.created_at < ? AND transferencia_gerais.valor > 0" , inicio_mes, fim_mes).where(cancelada: [nil, false], tipo: ["VENDA", "VENDA_DIRETA"]).sum(:valor)
  end

  def saldo_em_caixa
    self.transferencias.where(tipo: ['ENTRADA','SAIDA','VENDA_DIRETA','SAIDA CANCELADA','DEPOSITO CANCELADO','REEMBOLSO_VENDA_DIRETA','AJUSTE','REEMBOLSO_VENDA_DIRETA_PRODUTO']).sum(&:valor)
  end

  def self.criar_escola(nome)
    escola = Escola.new(nome: nome, sem_credito: true)

    escola.tipo_users.new(nome: "Administrador", codigo: "admin", bloqueado: true)
    escola.tipo_users.new(nome: "Aluno", codigo: "aluno", bloqueado: true)
    escola.tipo_users.new(nome: "Responsável", codigo: "responsavel", bloqueado: true)
    escola.users.new(nome: "SISTEMA", email:"sistema_#{nome}@sistemacantinapro.com.br", codigo:"SISTEMA___#{nome}___1", password: 123456, sistema: true, saldo: 0)
    escola.users.new(nome: "Admin", email:"admin_#{nome}@sistemacantinapro.com.br", codigo:"admin", password: 123456, sistema: false, ativo: true, saldo: 0, admin: true)
    escola.tipo_produtos.new(nome: "Salgados")
    escola.tipo_produtos.new(nome: "Bebidas")
    escola.tipo_produtos.new(nome: "Outros")
    escola.tipo_creditos.new(tipo: "Dinheiro")
    escola.cardapios.new(nome: "Padrão", ativo: true)

    escola.save!

    puts escola.id
  end

  def inicio_dia
  end

  def fim_dia
  end

end
