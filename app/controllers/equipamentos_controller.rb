class EquipamentosController < ApplicationController

  skip_before_action :verify_authenticity_token, :only => [:login_equipamento, :login_totem]

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
      all_combos << {nome: combo.nome, id: combo.id, preco: cardapio_ativo.cardapio_combos.where(combo_id: combo.id).last.preco.to_f, url: combo.imagem.url, produtos: combo.combo_produto_ids, tipo_produtos: combo.combo_tipo_produto_ids}
    end
    
    all_tipos = []
    TipoProduto.where(id: @produtos_cardapio.map(&:tipo_produto_id)).each do |tipo|
      all_tipos << {nome: tipo.nome, id: tipo.id}
    end

    produtos_agrupados = @produtos_cardapio.group_by { |d| d[:tipo_produto_id] }
    produtos_agrupados.each do |tipo_produto_id, produtos|

    end

    return { status: 200, saldo_disponivel: user.saldo_diario_atual, cardapio_produto_ids: produtos_agrupados, all_produtos: all_produtos, all_combos: all_combos, all_tipos: all_tipos }


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
end
