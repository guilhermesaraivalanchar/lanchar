class ComprasController < ApplicationController
  def index

    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("comprar_sistema")

  	cardapio_ativo = Cardapio.where(escola_id: current_user.escola_id, ativo: true).last

		cardapio_produto_ids = cardapio_ativo.cardapio_produtos.joins(:produto).where('produtos.quantidade > 0').map(&:produto_id)
		cardapio_combo_ids = []

    cardapio_ativo.cardapio_combos.each do |cardapio_combo|
      nao_entrar = false
      cardapio_combo.combo.combo_produtos.each do |combo_produto|
        if combo_produto.produto.quantidade <= 0
          nao_entrar = true
        end
      end
      cardapio_combo_ids << cardapio_combo.combo_id if !nao_entrar
    end


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
    
    if current_user.tem_permissao("comprar_sistema")
      cardapio_ativo = Cardapio.where(ativo: true).last

      resposta = []

      params[:confirmacao].each do |conf|

        user_id = conf.last[:user_id]

        transf_geral = TransferenciaGeral.new(user_id: user_id, escola_id: current_user.escola_id, tipo: "VENDA")
        preco_total = 0
        if transf_geral.save

          conf.last[:produtos].each do |prod_combo|

            if prod_combo.last[:tipo] == "p"
              prod_preco = cardapio_ativo.cardapio_produtos.where(produto_id: prod_combo.last[:id]).last.preco.to_f
              Transferencia.create(escola_id: current_user.escola_id, tipo: "VENDA", user_movimentou_id: current_user.id, transferencia_geral_id: transf_geral.id, produto_id: prod_combo.last[:id], valor: prod_preco)
              produto = Produto.find(prod_combo.last[:id])
              produto.update_attribute(:quantidade, produto.quantidade.to_d - 1)
              preco_total += prod_preco
            elsif prod_combo.last[:tipo] == "c"
              combo_preco = cardapio_ativo.cardapio_combos.where(combo_id: prod_combo.last[:id]).last.preco.to_f
              transf = Transferencia.new(escola_id: current_user.escola_id, tipo: "VENDA", user_movimentou_id: current_user.id, transferencia_geral_id: transf_geral.id, combo_id: prod_combo.last[:id], valor: combo_preco)
              preco_total += combo_preco
              if transf.save
                prod_combo.last[:produtos].each do |prod_id|
                  TransferenciaCombo.create(transferencia_id: transf.id, produto_id: prod_id)
                  produto = Produto.find(prod_id)
                  produto.update_attribute(:quantidade, produto.quantidade.to_d - 1)
                end
              end
            end
          end

          transf_geral.update_attribute(:valor, preco_total)
          transf_geral.user.update_attribute(:saldo, transf_geral.user.saldo.to_d - preco_total.to_d)
          resposta << {
            div_confirmacao_id: conf.last[:div_confirmacao_id],
            transf_geral_id: transf_geral.id
          }

        end

      end

      render json: { status: "OK", resposta: resposta}
    else
      render json: { status: "NEGADO", resposta: ""}
    end

  end



end
