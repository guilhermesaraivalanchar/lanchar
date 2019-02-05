class EquipamentosController < ApplicationController

  skip_before_action :verify_authenticity_token, :only => [:login_equipamento, :login_totem, :finalizar_compra, :alt_senha_user]

  #before_action :authenticate_totem

  def authenticate_totem
    @equipamento = Equipamento.where(token: params[:t]).first if params[:t]

    render json: {}, status: 403 if !@equipamento
  end


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

      if u.ativo
        if senhas_possiveis.include?(u.senha_totem)
          render json: usuario_info(u)
        else
          render json: { status: "SENHA_INCORRETA" }
        end
      else
        render json: { status: "USUARIO_INATIVO" }
      end

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

    @produtos_cardapio = Produto.where(id: cardapio_produto_ids, ativo: true)
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

    status_user = user.senha_totem == "0000" ? "SENHA_INICIAL" : 200

    return { status: status_user, user_nome: user.nome, user_id: user.id, saldo_total: user.saldo, saldo_credito: user.credito, saldo_disponivel: user.saldo_diario_atual, saldo_diario: user.saldo_diario, user_url: URI::escape(user.imagem.url), cardapio_produto_ids: produtos_agrupados, all_produtos: all_produtos, all_combos: all_combos, all_tipos: all_tipos }


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

    usuario_compra = User.find(params[:user_id])
    saldo_ant = usuario_compra ? usuario_compra.saldo.to_d : 0
    user_movimentou_id = # DADGE
    transf_geral = TransferenciaGeral.new(user_id: usuario_compra.id, escola_id: usuario_compra.escola_id, tipo: "VENDA", user_movimentou_id: user_movimentou_id, saldo_anterior: saldo_ant.to_d)
    valor_transf = 0
    preco_total = 0
    
    produtos_update = []
    erro_produtos_quantidade = []
    params[:lista].each do |num, prod_combo|

      if prod_combo[:produto_id]
        prod_preco = prod_combo[:preco].to_d
        valor_transf = valor_transf + prod_preco
        transf_geral.transferencias.new(escola_id: usuario_compra.escola_id, tipo: "VENDA", user_movimentou_id: user_movimentou_id, produto_id: prod_combo[:produto_id], valor: prod_preco, saldo_anterior: saldo_ant.to_d - valor_transf)
        produto = Produto.find(prod_combo[:produto_id])

        if produto.quantidade > produtos_update.select{ |p| p[:id] == prod_combo[:produto_id].to_i }.count
          produtos_update << produto
          #produto.update_attribute(:quantidade, produto.quantidade.to_d - 1)
        else
          erro_produtos_quantidade << produto.nome
        end
        preco_total += prod_preco
      else
        combo_preco = prod_combo[:preco].to_d
        valor_transf = valor_transf + combo_preco
        transf = transf_geral.transferencias.new(escola_id: usuario_compra.escola_id, tipo: "VENDA", user_movimentou_id: user_movimentou_id, combo_id: prod_combo[:id], valor: combo_preco, saldo_anterior: saldo_ant.to_d - valor_transf)
        preco_total += combo_preco

        prod_combo[:produtos].each do |prod_id|
          transf.transferencia_combos.new(produto_id: prod_id)
          produto = Produto.find(prod_id)
          if produto.quantidade > produtos_update.select{ |p| p[:id] == prod_id.to_i }.count
            produtos_update << produto
            #produto.update_attribute(:quantidade, produto.quantidade.to_d - 1)
          else
            erro_produtos_quantidade << produto.nome
          end
        end

      end
    end

    transf_geral.valor = preco_total

    if erro_produtos_quantidade.empty?
      if transf_geral.save
        transf_geral.user.update_attribute(:saldo, transf_geral.user.saldo.to_d - preco_total.to_d) if transf_geral.user
        produtos_update.each do |produto|
          produto.update_attribute(:quantidade, produto.quantidade.to_d - 1)
        end

        render json: { status: "OK", transferencia: transf_geral.id }

      else
        render json: { status: "ERRO_AO_SALVAR" }
      end
    else
      render json: { status: "ERRO_QUANTIDADE_PRODUTO", produtos: erro_produtos_quantidade }
    end
  end

  def alt_senha_user

    User.find(params[:user_id]).update_attribute(:senha_totem,params[:senha])
    render json: { status: "SALVO" }
    
  end
end
