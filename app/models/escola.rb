class Escola < ApplicationRecord
	
	has_many :users
	has_many :produtos
	has_many :combos
	has_many :transferencia_gerais
	has_many :transferencias
	has_many :cardapios
	has_many :tipo_produtos
	has_many :tipo_users
	has_many :fornecedores

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
		self.transferencias.where(tipo: ['ENTRADA','SAIDA','VENDA_DIRETA','SAIDA CANCELADA']).sum(:valor)
	end
end
