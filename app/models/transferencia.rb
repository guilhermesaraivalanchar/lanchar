class Transferencia < ApplicationRecord
  belongs_to :escola
  belongs_to :transferencia_geral
  belongs_to :produto, optional: true
  belongs_to :combo, optional: true
  belongs_to :equipamento, optional: true
  has_many :transferencia_combos, :dependent => :destroy

  after_save :att_caixa

  def att_caixa
    caixa = nil
    
    if ['REEMBOLSO_VENDA_DIRETA_PRODUTO'].include?(self.tipo)
      caixa = Caixa.where(user_id: self.user_movimentou_id).first_or_initialize
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

    puts "CANCELAR "
    puts "CANCELAR "
    puts "CANCELAR "

    if self.tipo == "VENDA"

      comprador = self.transferencia_geral.user
      saldo_ant = comprador.saldo.to_d

      puts "CANCELAR VENDA"
      puts "CANCELAR VENDA"
      puts "CANCELAR VENDA"
      puts comprador.inspect
      puts "CANCELAR VENDA"

      if comprador.update_attribute(:saldo, comprador.saldo.to_d + self.valor.to_d)
        puts "CANCELAR VENDA comprador"
        puts "CANCELAR VENDA comprador"
        tf = TransferenciaGeral.new(user_id: comprador.id, valor: self.valor.to_d, escola_id: current_user.escola_id, tipo: "REEMBOLSO_PRODUTO", user_movimentou_id: current_user.id)
        tf.transferencias.new(user_movimentou_id: current_user.id, valor: self.valor.to_d, escola_id: current_user.escola_id, tipo:"REEMBOLSO_PRODUTO", saldo_anterior: saldo_ant.to_d + self.valor.to_d)
        tf.save
        puts tf.errors.inspect

      end

      self.produto.update_attribute(:quantidade, self.produto.quantidade + 1) if self.produto
      
      if self.combo
        self.transferencia_combos.each do |transferencia_combo|
          produto_combo = transferencia_combo.produto
          produto_combo.update_attribute(:quantidade, produto_combo.quantidade + 1)
          transferencia_combo.update_attribute(:cancelada, true)
        end
      end 

      self.update_columns(cancelada: true, data_cancelada: DateTime.now, user_cancelou_id: current_user.id)

    elsif self.tipo == "VENDA_DIRETA"

      comprador = User.where(escola_id: self.escola_id, sistema: true).last

      tf = TransferenciaGeral.new(user_id: comprador.id, valor: self.valor.to_d*(-1), escola_id: current_user.escola_id, tipo: "REEMBOLSO_VENDA_DIRETA_PRODUTO", user_movimentou_id: current_user.id)
      tf.transferencias.new(user_movimentou_id: current_user.id, valor: self.valor.to_d*(-1), escola_id: current_user.escola_id, tipo:"REEMBOLSO_VENDA_DIRETA_PRODUTO", saldo_anterior: 0, user_movimentou_id: current_user.id )
      tf.save

      self.produto.update_attribute(:quantidade, self.produto.quantidade + 1) if self.produto
      
      if self.combo
        self.transferencia_combos.each do |transferencia_combo|
          produto_combo = transferencia_combo.produto
          produto_combo.update_attribute(:quantidade, produto_combo.quantidade + 1)
          transferencia_combo.update_attribute(:cancelada, true)
        end
      end 

      self.update_columns(cancelada: true, data_cancelada: DateTime.now, user_cancelou_id: current_user.id)


    end
  end
end
