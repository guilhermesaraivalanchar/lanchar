class ComprasController < ApplicationController
  def index

  	cardapio_ativo = Cardapio.where(ativo: true).last

		cardapio_produto_ids = cardapio_ativo.cardapio_produtos.map(&:produto_id)
		cardapio_combo_ids = cardapio_ativo.cardapio_combos.map(&:combo_id)

  	@produtos_cardapio = Produto.where(id: cardapio_produto_ids).collect { |m| [m.nome, m.id] }
  	@combos_cardapio = Combo.where(id: cardapio_combo_ids).collect { |m| [m.nome, m.id] }

  	@produtos_cardapio_string = ""
  	@produtos_cardapio.each do |produto|
  		@produtos_cardapio_string += "#{produto.first}::#{produto.last}::#{cardapio_ativo.cardapio_produtos.where(produto_id: produto.last).last.preco.to_f}..."
  	end
		
  	@combos_cardapio_string = ""
  	@combos_cardapio.each do |combo|
  		@combos_cardapio_string += "#{combo.first}::#{combo.last}::#{cardapio_ativo.cardapio_combos.where(combo_id: combo.last).last.preco.to_f}..."
  	end
		
		@select_prod_options = "<option value='0'>Escolha um produto</option>"
    @produtos_cardapio.each do |produto|
    	@select_prod_options += "<option value='#{produto.last}'>#{produto.first} (R$  #{cardapio_ativo.cardapio_produtos.where(produto_id: produto.last).last.preco.to_f})</option>"
    end

		@select_combo_options = "<option value='0'>Escolha um combo</option>"
    @combos_cardapio.each do |combo|
    	@select_combo_options += "<option value='#{combo.last}'>#{combo.first} (R$ #{cardapio_ativo.cardapio_combos.where(combo_id: combo.last).last.preco.to_f} ) </option>"
    end
  end

  def get_dados_combo

  	combo = Combo.find(params[:combo_id])

  	combo_detalhe = []
  	produto_detalhe = []
  	combo.combo_tipo_produtos.each do |combo_tipo|
			
			select_prod_options = "<option value='0'>Escolha seu/sua #{combo_tipo.tipo_produto.nome.singularize}</option>"
	    Produto.where(tipo_produto_id: combo_tipo.tipo_produto_id).collect { |m| [m.nome, m.id] }.each do |produto|
	    	select_prod_options += "<option value='#{produto.last}'>#{produto.first}</option>"
	    end

	    combo_detalhe << {
	    	tipo: combo_tipo.tipo_produto.nome,
	    	opcoes: select_prod_options
	    }

  	end


  	 combo.combo_produtos.each do |combo_produto|
			
	    produto_detalhe << {
	    	nome: combo_produto.produto.nome,
	    	id: combo_produto.produto.id
	    }

  	end

    render json: { tipo_produtos: combo_detalhe, produtos: produto_detalhe }

  end

  def enviar_confirmacao_compra
    
    cardapio_ativo = Cardapio.where(ativo: true).last

    params[:confirmacao].each do |conf|

      user_id = conf.last[:user_id]

      transf_geral = TransferenciaGeral.new(user_id: user_id)
      preco_total = 0
      if transf_geral.save

        conf.last[:produtos].each do |prod_combo|

          if prod_combo.last[:tipo] == "p"
            prod_preco = cardapio_ativo.cardapio_produtos.where(produto_id: prod_combo.last[:id]).last.preco.to_f
            Transferencia.create(user_movimentou_id: current_user.id, transferencia_geral_id: transf_geral.id, produto_id: prod_combo.last[:id], valor: prod_preco)
            preco_total += prod_preco
          elsif prod_combo.last[:tipo] == "c"
            combo_preco = cardapio_ativo.cardapio_combos.where(combo_id: prod_combo.last[:id]).last.preco.to_f
            transf = Transferencia.new(user_movimentou_id: current_user.id, transferencia_geral_id: transf_geral.id, combo_id: prod_combo.last[:id], valor: combo_preco)
            preco_total += combo_preco
            if transf.save
              prod_combo.last[:produtos].each do |prod_id|
                TransferenciaCombo.create(transferencia_id: transf.id, produto_id: prod_id)
              end
            end
          end
        end

        transf_geral.update_attribute(:valor, preco_total)
      end

    end

    render json: { status: "OK"}

  end



end
