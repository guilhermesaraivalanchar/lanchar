class TransferenciaGeral < ApplicationRecord
  
  belongs_to :escola
  belongs_to :user, optional: true
  belongs_to :caixa, optional: true
  belongs_to :tipo_credito, optional: true
  belongs_to :equipamento, optional: true
  has_many :transferencias, :dependent => :destroy

  after_save :att_caixa

  def saida?
    self.tipo == "SAIDA"
  end

  def entrada?
    self.tipo == "ENTRADA"
  end

  def venda?
    self.tipo == "VENDA"
  end

  def venda_direta?
    self.tipo == "VENDA_DIRETA"
  end

  def att_caixa
    caixa = nil
    if ['ENTRADA','VENDA_DIRETA','DEPOSITO CANCELADO','REEMBOLSO_VENDA_DIRETA', 'AJUSTE'].include?(self.tipo)
      caixa = Caixa.where(user_id: self.user_movimentou_id).first_or_initialize
    elsif ['SAIDA','SAIDA CANCELADA'].include?(self.tipo)
      caixa = Caixa.where(user_id: self.user_caixa_id).first_or_initialize
    end

    if caixa
      valor_caixa = caixa.new_record? ? self.valor : ( caixa.valor + self.valor )
      caixa.valor = valor_caixa < 0 ? 0 : valor_caixa
      caixa.save
      self.update_column(:caixa_id, caixa.id)
      LogCaixa.create(caixa_id: caixa.id, valor: caixa.valor, transferencia_geral_id: self.id)
    end

  end

  def cancelar(current_user)

    if self.tipo == "VENDA"

      comprador = self.user
      saldo_ant = comprador.saldo.to_d

      cancelar_valor = self.transferencias.where(cancelada: [false, nil]).sum(&:valor)

      if comprador.update_attribute(:saldo, comprador.saldo.to_d + cancelar_valor.to_d)
        tf = TransferenciaGeral.new(user_id: comprador.id, valor: cancelar_valor.to_d, escola_id: current_user.escola_id, tipo: "REEMBOLSO", user_movimentou_id: current_user.id)
        tf.transferencias.new(user_movimentou_id: current_user.id, valor: cancelar_valor.to_d, escola_id: current_user.escola_id, tipo:"REEMBOLSO", saldo_anterior: saldo_ant.to_d + cancelar_valor.to_d)
        tf.save
      end
      self.transferencias.where(cancelada: [nil, false]).each do |transferencia|
        transferencia.produto.update_attribute(:quantidade, transferencia.produto.quantidade + 1) if transferencia.produto
        
        if transferencia.combo
          transferencia.transferencia_combos.each do |transferencia_combo|
            produto_combo = transferencia_combo.produto
            produto_combo.update_attribute(:quantidade, produto_combo.quantidade + 1)
            transferencia_combo.update_attribute(:cancelada, true)
          end
        end 

        transferencia.update_attributes(cancelada: true, data_cancelada: DateTime.now, user_cancelou_id: current_user.id)
      end
      self.update_columns(cancelada: true, data_cancelada: DateTime.now, user_cancelou_id: current_user.id)

    elsif self.tipo == "ENTRADA"
      beneficiado = self.user
      saldo_ant = beneficiado.saldo.to_d
      if beneficiado.update_attribute(:saldo, beneficiado.saldo.to_d - self.valor.to_d)
        tf = TransferenciaGeral.new(user_id: beneficiado.id, valor: self.valor.to_d*(-1), escola_id: current_user.escola_id, tipo: "DEPOSITO CANCELADO", user_movimentou_id: current_user.id)
        tf.transferencias.new(user_movimentou_id: current_user.id, valor: self.valor.to_d*(-1), escola_id: current_user.escola_id, tipo:"DEPOSITO CANCELADO", saldo_anterior: saldo_ant.to_d - self.valor.to_d)
        tf.save
      end
      self.transferencias.update_all(cancelada: true, data_cancelada: DateTime.now, user_cancelou_id: current_user.id)
      self.update_columns(cancelada: true, data_cancelada: DateTime.now, user_cancelou_id: current_user.id)

    elsif self.tipo == "SAIDA"

      tf = TransferenciaGeral.new(valor: self.valor.to_d*(-1), escola_id: current_user.escola_id, tipo: "SAIDA CANCELADA", user_caixa_id: self.user_caixa_id, user_movimentou_id: current_user.id)
      tf.transferencias.new(user_movimentou_id: current_user.id, valor: self.valor.to_d*(-1), escola_id: current_user.escola_id, tipo:"SAIDA CANCELADA", user_movimentou_id: current_user.id, user_caixa_id: self.user_caixa_id)
      tf.save

      self.transferencias.update_all(cancelada: true, data_cancelada: DateTime.now, user_cancelou_id: current_user.id)
      self.update_columns(cancelada: true, data_cancelada: DateTime.now, user_cancelou_id: current_user.id)


    elsif self.tipo == "VENDA_DIRETA"

      comprador = User.where(escola_id: self.escola_id, sistema: true).last

      cancelar_valor = self.transferencias.where(cancelada: [false, nil]).sum(&:valor)

      tf = TransferenciaGeral.new(user_id: comprador.id, valor: cancelar_valor.to_d*(-1), escola_id: current_user.escola_id, tipo: "REEMBOLSO_VENDA_DIRETA", user_movimentou_id: current_user.id)
      tf.transferencias.new(user_movimentou_id: current_user.id, valor: cancelar_valor.to_d*(-1), escola_id: current_user.escola_id, tipo:"REEMBOLSO_VENDA_DIRETA", saldo_anterior: 0)
      tf.save

      self.transferencias.where(cancelada: [nil, false]).each do |transferencia|
        transferencia.produto.update_attribute(:quantidade, transferencia.produto.quantidade + 1) if transferencia.produto
        
        if transferencia.combo
          transferencia.transferencia_combos.each do |transferencia_combo|
            produto_combo = transferencia_combo.produto
            produto_combo.update_attribute(:quantidade, produto_combo.quantidade + 1)
            transferencia_combo.update_attribute(:cancelada, true)
          end
        end 

        transferencia.update_attributes(cancelada: true, data_cancelada: DateTime.now, user_cancelou_id: current_user.id)
      end
      self.update_columns(cancelada: true, data_cancelada: DateTime.now, user_cancelou_id: current_user.id)


    end
  end
end
