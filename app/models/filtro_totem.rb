class FiltroTotem < ApplicationRecord

  has_many :filtro_totem_produtos, :dependent => :destroy
  
  attr_accessor :produto_ids
  attr_accessor :enable_after_save

  after_save :att_produtos, :if => :enable_after_save

  def att_produtos
    self.filtro_totem_produtos.destroy_all
    if produto_ids
      self.produto_ids.each do |produto_id|
        per = FiltroTotemProduto.create(filtro_totem_id: self.id, produto_id: produto_id.to_i)
        if per
          puts " CRIO"

        else
          puts "nao"
          puts per.errors.inspect

        end
      end
    end
  end
end
