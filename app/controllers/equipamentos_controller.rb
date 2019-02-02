class EquipamentosController < ApplicationController

  skip_before_action :verify_authenticity_token, :only => [:login_equipamento, :login_totem, :finalizar_compra]

  def login_equipamento

  end

  def show
    
    
  end

  def equipamento_page
  end

  def login_totem

    u = User.where(codigo: params[:c].to_i).last
    
    if u 

      senhas_possiveis = gerar_possiveis_senhas(params[:p])
      senhas_possiveis.include?(u.senha_totem)

      render json: usuario_info(u)
    else
      
      render json: { status: "CODIGO_NAO_ENCONTRADO" }
    end

  end

  def autenticar_login(params)
  	true
  end

  def usuario_info(user)
  	puts "

  	#{user.inspect}


  	"

    cardapio_ativo = Cardapio.where(escola_id: user.escola_id, ativo: true).last

    cardapio_produto_ids = cardapio_ativo.cardapio_produtos.joins(:produto).where('produtos.quantidade > 0').map(&:produto_id)
    cardapio_combo_ids = []

    cardapio_ativo.cardapio_combos.each do |cardapio_combo|
      nao_entrar = false
      cardapio_combo.combo.combo_produtos.each do |combo_produto|
        if combo_produto.produto.quantidade <= 0 || user.bloqueio_produtos.map(&:produto_id).include?(combo_produto.produto.id)
          nao_entrar = true
        end
      end
      cardapio_combo_ids << cardapio_combo.combo_id if !nao_entrar
    end

    cardapio_produto_ids = cardapio_produto_ids - user.bloqueio_produtos.map(&:produto_id)

    @produtos_cardapio = Produto.where(id: cardapio_produto_ids)
    @combos_cardapio = Combo.where(id: cardapio_combo_ids)


    all_produtos = []
    @produtos_cardapio.each do |produto|
      all_produtos << {nome: produto.nome, id: produto.id, preco: cardapio_ativo.cardapio_produtos.where(produto_id: produto.id).last.preco.to_f, quantidade: produto.quantidade, url: URI::escape(produto.imagem.url), tipo_produto: produto.tipo_produto_id}
    end

    all_combos = []
    @combos_cardapio.each do |combo|
      all_combos << {nome: combo.nome, id: combo.id, preco: cardapio_ativo.cardapio_combos.where(combo_id: combo.id).last.preco.to_f, url: URI::escape(combo.imagem.url), produtos: combo.combo_produtos.map(&:produto_id), tipo_produtos: combo.combo_tipo_produtos.map(&:tipo_produto_id)}
    end
    
    all_tipos = []
    TipoProduto.where(id: @produtos_cardapio.map(&:tipo_produto_id)).each do |tipo|
      all_tipos << {nome: tipo.nome, id: tipo.id}
    end

    produtos_agrupados = @produtos_cardapio.group_by { |d| d[:tipo_produto_id] }
    produtos_agrupados.each do |tipo_produto_id, produtos|

    end

    return { status: 200, user_nome: user.nome, user_id: user.id, saldo_disponivel: user.saldo_diario_atual, user_url: URI::escape(user.imagem.url), cardapio_produto_ids: produtos_agrupados, all_produtos: all_produtos, all_combos: all_combos, all_tipos: all_tipos }


  end

  def gerar_possiveis_senhas(senhas)

    p1 = []
    p2 = []
    p3 = []
    p4 = []

    i = 1
    senhas.each do |pe, po|
      p1 = po.map(&:to_i) if i == 1
      p2 = po.map(&:to_i) if i == 2
      p3 = po.map(&:to_i) if i == 3
      p4 = po.map(&:to_i) if i == 4
      i += 1
    end

    senhas_possiveis = []

    senhas_possiveis << "#{p1[0]}#{p2[0]}#{p3[0]}#{p4[0]}"
    senhas_possiveis << "#{p1[0]}#{p2[0]}#{p3[0]}#{p4[1]}"
    senhas_possiveis << "#{p1[0]}#{p2[0]}#{p3[1]}#{p4[0]}"
    senhas_possiveis << "#{p1[0]}#{p2[0]}#{p3[1]}#{p4[1]}"
    senhas_possiveis << "#{p1[0]}#{p2[1]}#{p3[0]}#{p4[0]}"
    senhas_possiveis << "#{p1[0]}#{p2[1]}#{p3[0]}#{p4[1]}"
    senhas_possiveis << "#{p1[0]}#{p2[1]}#{p3[1]}#{p4[0]}"
    senhas_possiveis << "#{p1[0]}#{p2[1]}#{p3[1]}#{p4[1]}"
    senhas_possiveis << "#{p1[1]}#{p2[0]}#{p3[0]}#{p4[0]}"
    senhas_possiveis << "#{p1[1]}#{p2[0]}#{p3[0]}#{p4[1]}"
    senhas_possiveis << "#{p1[1]}#{p2[0]}#{p3[1]}#{p4[0]}"
    senhas_possiveis << "#{p1[1]}#{p2[0]}#{p3[1]}#{p4[1]}"
    senhas_possiveis << "#{p1[1]}#{p2[1]}#{p3[0]}#{p4[0]}"
    senhas_possiveis << "#{p1[1]}#{p2[1]}#{p3[0]}#{p4[1]}"
    senhas_possiveis << "#{p1[1]}#{p2[1]}#{p3[1]}#{p4[0]}"
    senhas_possiveis << "#{p1[1]}#{p2[1]}#{p3[1]}#{p4[1]}"

    return senhas_possiveis

  end

  def finalizar_compra

    puts "


      #{params.inspect}


    "





    params[:lista].each do |num, lista|

      puts "


        #{num}


        #{lista.inspect}

        #{lista[:produto_id] ? lista[:produto_id] : "-"}

        #{lista[:produtos]}


      "
    end




    usuario_compra = User.find(params[:user_id])
    saldo_ant = usuario_compra ? usuario_compra.saldo.to_d : 0
    user_movimentou_id = # DADGE
    transf_geral = TransferenciaGeral.new(user_id: usuario_compra.id, escola_id: usuario_compra.escola_id, tipo: "VENDA", user_movimentou_id: user_movimentou_id, saldo_anterior: saldo_ant.to_d)
    valor_transf = 0
    preco_total = 0
    
    produtos_update = []

    params[:lista].each do |num, prod_combo|

      if prod_combo[:produto_id]
        prod_preco = prod_combo[:preco]
        valor_transf = valor_transf + prod_preco
        transf_geral.transferencias.new(escola_id: usuario_compra.escola_id, tipo: "VENDA", user_movimentou_id: user_movimentou_id, produto_id: prod_combo[:produto_id], valor: prod_preco, saldo_anterior: saldo_ant.to_d - valor_transf)
        produto = Produto.find(prod_combo[:produto_id])
        if produto.quantidade > 0
          produtos_update << prod_combo[:produto_id]
          produto.update_attribute(:quantidade, produto.quantidade.to_d - 1)
        else
          erro_produtos_quantidade << produto.nome
        end
        preco_total += prod_preco
      elsif prod_combo.last[:tipo] == "c"
        combo_preco = cardapio_ativo.cardapio_combos.where(combo_id: prod_combo.last[:id]).last.preco.to_f
        valor_transf = valor_transf + combo_preco
        transf = transf_geral.transferencias.new(escola_id: current_user.escola_id, tipo: "VENDA", user_movimentou_id: current_user.id, combo_id: prod_combo.last[:id], valor: combo_preco, saldo_anterior: saldo_ant.to_d - valor_transf)
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

    transf_geral.valor = preco_total









    render json: { status: "CODIGO_NAO_ENCONTRADO" }



  end
end
