class TransferenciaGeral < ApplicationRecord
  
  belongs_to :escola
  belongs_to :user, optional: true
  has_many :transferencias, :dependent => :destroy

  def cancelar(current_user)

    comprador = self.user

    if comprador.update_attribute(:saldo, comprador.saldo.to_d + self.valor.to_d)
      tf = TransferenciaGeral.new(user_id: comprador.id, valor: self.valor.to_d, escola_id: current_user.escola_id, tipo: "REEMBOLSO")
      tf.transferencias.new(user_movimentou_id: current_user.id, valor: self.valor.to_d, escola_id: current_user.escola_id, tipo:"REEMBOLSO")
      tf.save
    end
    self.transferencias.each do |transferencia|
      transferencia.produto.update_attribute(:quantidade, transferencia.produto.quantidade + 1) if transferencia.produto
      
      if transferencia.combo
        transferencia.transferencia_combos.each do |transferencia_combo|
          produto_combo = transferencia_combo.produto
          produto_combo.update_attribute(:quantidade, produto_combo.quantidade + 1)
          transferencia_combo.update_attribute(:cancelada, true)
        end
      end 

      transferencia.update_attribute(:cancelada, true)
    end
    self.update_attribute(:cancelada, true)

  end
end
