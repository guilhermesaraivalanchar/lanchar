class ComprasController < ApplicationController
  def index

    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("comprar_sistema")

  	cardapio_ativo = Cardapio.where(escola_id: current_user.escola_id, ativo: true).last

		cardapio_produto_ids = cardapio_ativo.cardapio_produtos.joins(:produto).where('cardapio_produtos.ativo = ?',true).where('produtos.quantidade > 0 and produtos.ativo = ?',true).map(&:produto_id)
		cardapio_combo_ids = []

    cardapio_ativo.cardapio_combos.where(ativo: true).each do |cardapio_combo|
      nao_entrar = false
      cardapio_combo.combo.combo_produtos.each do |combo_produto|
        if combo_produto.produto.quantidade <= 0 || !combo_produto.produto.ativo
          nao_entrar = true
        end
      end
      cardapio_combo_ids << cardapio_combo.combo_id if !nao_entrar
    end


  	@produtos_cardapio = Produto.where(id: cardapio_produto_ids, ativo: true)
  	@combos_cardapio = Combo.where(id: cardapio_combo_ids).collect { |m| [m.nome, m.id] }

  	@produtos_cardapio_string = ""
  	@produtos_cardapio.each do |produto|
  		@produtos_cardapio_string += "#{produto.nome}::#{produto.id}::#{cardapio_ativo.cardapio_produtos.where(produto_id: produto.id).last.preco.to_f}::#{produto.quantidade}..."
  	end
		
  	@combos_cardapio_string = ""
  	@combos_cardapio.each do |combo|
  		@combos_cardapio_string += "#{combo.first}::#{combo.last}::#{cardapio_ativo.cardapio_combos.where(ativo: true).where(combo_id: combo.last).last.preco.to_f}..."
  	end
		
		@select_prod_options = "<option value='0'>Escolha um produto</option>"
    @produtos_cardapio.each do |produto|
    	@select_prod_options += "<option value='#{produto.id}'>#{produto.nome} (R$  #{cardapio_ativo.cardapio_produtos.where(produto_id: produto.id).last.preco.to_f})</option>"
    end

		@select_combo_options = "<option value='0'>Escolha um combo</option>"
    @combos_cardapio.each do |combo|
    	@select_combo_options += "<option value='#{combo.last}'>#{combo.first} (R$ #{cardapio_ativo.cardapio_combos.where(ativo: true).where(combo_id: combo.last).last.preco.to_f} ) </option>"
    end
  end

  def get_dados_combo

  	combo = Combo.find(params[:combo_id])

  	combo_detalhe = []
  	produto_detalhe = []
  	combo.combo_tipo_produtos.each do |combo_tipo|
			
			select_prod_options = "<option value='0'>Escolha seu/sua #{combo_tipo.tipo_produto.nome.singularize}</option>"
	    Produto.where('produtos.quantidade > 0').where(tipo_produto_id: combo_tipo.tipo_produto_id).collect { |m| [m.nome, m.id] }.each do |produto|
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

      if params[:confirmacao]
        params[:confirmacao].each do |conf|


          erro_produtos_quantidade = []
          user_id = conf.last[:user_id]

          ig_saldo = conf.last[:ignorar_saldo] == "true"

          if user_id
            tipo_transacao = "VENDA"
            tipo_transacao = "VENDA_DIRETA" if user_id == "0"

            
            if user_id != "0"
              u = User.find(user_id)
              saldo_ant = u ? u.saldo.to_d : 0
            else
              saldo_ant = 0
            end


            transf_geral = TransferenciaGeral.new(user_id: user_id, escola_id: current_user.escola_id, tipo: tipo_transacao, user_movimentou_id: current_user.id, saldo_anterior: saldo_ant.to_d, ig_saldo: ig_saldo)
            valor_transf = 0
            preco_total = 0

            if conf && conf.last && conf.last[:produtos]
              conf.last[:produtos].each do |prod_combo|

                if prod_combo.last[:tipo] == "p"
                  prod_preco = cardapio_ativo.cardapio_produtos.where(produto_id: prod_combo.last[:id]).last.preco.to_f
                  valor_transf = valor_transf + prod_preco
                  transf_geral.transferencias.new(escola_id: current_user.escola_id, tipo: tipo_transacao, user_movimentou_id: current_user.id, produto_id: prod_combo.last[:id], valor: prod_preco, saldo_anterior: saldo_ant.to_d - valor_transf)
                  produto = Produto.find(prod_combo.last[:id])
                  if produto.quantidade > 0
                    produto.update_attribute(:quantidade, produto.quantidade.to_d - 1)
                  else
                    erro_produtos_quantidade << produto.nome
                  end
                  preco_total += prod_preco
                elsif prod_combo.last[:tipo] == "c"
                  combo_preco = cardapio_ativo.cardapio_combos.where(ativo: true).where(combo_id: prod_combo.last[:id]).last.preco.to_f
                  valor_transf = valor_transf + combo_preco
                  transf = transf_geral.transferencias.new(escola_id: current_user.escola_id, tipo: tipo_transacao, user_movimentou_id: current_user.id, combo_id: prod_combo.last[:id], valor: combo_preco, saldo_anterior: saldo_ant.to_d - valor_transf)
                  preco_total += combo_preco

                  prod_combo.last[:produtos].each do |prod_id|
                    transf.transferencia_combos.new(produto_id: prod_id)
                    produto = Produto.find(prod_id)
                    if produto.quantidade > 0
                      produto.update_attribute(:quantidade, produto.quantidade.to_d - 1)
                    else
                      erro_produtos_quantidade << produto.nome
                    end
                  end

                end
              end
            end

            transf_geral.valor = preco_total

            debitar = true
            if tipo_transacao == "VENDA" && conf.last[:venda_com_entrada] == "true" && erro_produtos_quantidade.empty?
              
              saldo_ini_ant = saldo_ant.to_d + preco_total
              transf_geral.transferencias.each do |transf|
                transf.saldo_anterior = saldo_ini_ant - transf.valor
                saldo_ini_ant = saldo_ini_ant - transf.valor
              end
              
              debitar = false
              tipo_credito = TipoCredito.where(escola_id: current_user.escola_id, tipo: params[:tipo]).last.id rescue nil
              transf_geral_entrada = TransferenciaGeral.new(escola_id: current_user.escola_id, user_id: user_id, valor: preco_total.to_d, tipo: "ENTRADA", tipo_entrada: "dinheiro", tipo_credito_id: tipo_credito, user_movimentou_id: current_user.id, saldo_anterior: saldo_ant.to_d + preco_total)
              transf_geral_entrada.transferencias.new({
                escola_id: current_user.escola_id,
                user_movimentou_id: current_user.id,
                valor: preco_total.to_d,
                tipo: "ENTRADA",
                saldo_anterior: saldo_ant.to_d + preco_total
              })
              transf_geral_entrada.save
            end
            if erro_produtos_quantidade.empty?
              if transf_geral.save
                transf_geral.user.update_attribute(:saldo, transf_geral.user.saldo.to_d - preco_total.to_d) if transf_geral.user && debitar
                resposta << {
                  div_confirmacao_id: conf.last[:div_confirmacao_id],
                  transf_geral_id: transf_geral.id,
                  erro_produto: "SEM_PROBLEMAS"
                }
              end
            else
              resposta << {
                div_confirmacao_id: conf.last[:div_confirmacao_id],
                transf_geral_id: "-",
                erro_produto: erro_produtos_quantidade.join(",")
              }
            end




          end
        end
      end

      render json: { status: "OK", resposta: resposta}
    else
      render json: { status: "NEGADO", resposta: ""}
    end

  end

  def verificar_quantidade_produto

    flag_erro_quantidade = false
    produtos = []
    Produto.where(id: params[:produtos].uniq).each do |produto|
      

      if produto.quantidade <= 0
        produtos << produto.nome
        flag_erro_quantidade = true
      end

    end

    if flag_erro_quantidade
      render json: { status: "ERRO", produtos: produtos.join(", ")}
    else
      render json: { status: "OK"}
    end
  end

  def enviar_confirmacao_compra_old
    
    if current_user.tem_permissao("comprar_sistema")
      cardapio_ativo = Cardapio.where(ativo: true).last

      resposta = []

      params[:confirmacao].each do |conf|

        user_id = conf.last[:user_id]


        tipo_transacao = "VENDA"
        tipo_transacao = "VENDA_DIRETA" if user_id == "0"

        transf_geral = TransferenciaGeral.new(user_id: user_id, escola_id: current_user.escola_id, tipo: tipo_transacao, user_movimentou_id: current_user.id)
        preco_total = 0
        if transf_geral.save

          conf.last[:produtos].each do |prod_combo|

            if prod_combo.last[:tipo] == "p"
              prod_preco = cardapio_ativo.cardapio_produtos.where(produto_id: prod_combo.last[:id]).last.preco.to_f
              Transferencia.create(escola_id: current_user.escola_id, tipo: tipo_transacao, user_movimentou_id: current_user.id, transferencia_geral_id: transf_geral.id, produto_id: prod_combo.last[:id], valor: prod_preco)
              produto = Produto.find(prod_combo.last[:id])
              produto.update_attribute(:quantidade, produto.quantidade.to_d - 1)
              preco_total += prod_preco
            elsif prod_combo.last[:tipo] == "c"
              combo_preco = cardapio_ativo.cardapio_combos.where(ativo: true).where(combo_id: prod_combo.last[:id]).last.preco.to_f
              transf = Transferencia.new(escola_id: current_user.escola_id, tipo: tipo_transacao, user_movimentou_id: current_user.id, transferencia_geral_id: transf_geral.id, combo_id: prod_combo.last[:id], valor: combo_preco)
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
          transf_geral.user.update_attribute(:saldo, transf_geral.user.saldo.to_d - preco_total.to_d) if transf_geral.user
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
