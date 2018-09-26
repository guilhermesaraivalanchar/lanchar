class Combo < ApplicationRecord

	has_many :combo_produtos

  has_attached_file :imagem, :styles => { :original => "400x400>"}
  do_not_validate_attachment_file_type :imagem

  attr_accessor :produtos

  after_save :salvar_produtos

  def salvar_produtos
  	puts "








  	"
  	self.produtos.split(",").each do |produto_id|
  		ComboProduto.create(combo_id: self.id, produto_id: produto_id)
  	end
  end

end
