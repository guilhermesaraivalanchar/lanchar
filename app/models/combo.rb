class Combo < ApplicationRecord

  belongs_to :escola

	has_many :combo_produtos
  has_many :combo_tipo_produtos
  has_many :cardapio_combos
  has_many :transferencias

  has_attached_file :imagem, :styles => { :original => "400x400>"}
  do_not_validate_attachment_file_type :imagem

  attr_accessor :produtos
  attr_accessor :tipo_produtos

  after_save :salvar_produtos, :salvar_tipo_produtos

  def salvar_produtos
  	self.produtos.split(",").each do |produto_id|
  		ComboProduto.create(combo_id: self.id, produto_id: produto_id)
  	end
  end

  def salvar_tipo_produtos
    self.tipo_produtos.split(",").each do |tipo_produto_id|
      ComboTipoProduto.create(combo_id: self.id, tipo_produto_id: tipo_produto_id)
    end
  end
end
