class TransferenciaGeral < ApplicationRecord
  
  belongs_to :escola
  belongs_to :user, optional: true
  has_many :transferencias, :dependent => :destroy

  def cancelar

    comprador = self.user

    comprador.update_attribute(:saldo, comprador.saldo.to_d + self.valor.to_d)
    self.transferencias.each do |transferencia|
      transferencia.produto.update_attribcute(:quantidade, transferencia.produto.quantidade + 1) if transferencia.produto
      
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
