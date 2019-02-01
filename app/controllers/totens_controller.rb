class TotensController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:login]
  
  before_action :aut_cross
  before_action :authenticate_totem

  def login
    user = User.where(escola_id: params[:e], codigo: params[:c]).first

    if user && user.valid_password?(params[:p])

      cardapio_ativo = Cardapio.where(escola_id: params[:e], ativo: true).last

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


      @produtos_cardapio = Produto.where(id: cardapio_produto_ids)
      @combos_cardapio = Combo.where(id: cardapio_combo_ids)

      @produtos_cardapio_string = ""
      @produtos_cardapio.each do |produto|
        @produtos_cardapio_string += "#{produto.nome}::#{produto.id}::#{cardapio_ativo.cardapio_produtos.where(produto_id: produto.id).last.preco.to_f}::#{produto.quantidade}::#{produto.imagem.url}::#{produto.tipo_produto.id}..."
      end
      
      @combos_cardapio_string = ""
      @combos_cardapio.each do |combo|
        @combos_cardapio_string += "#{combo.nome}::#{combo.id}::#{cardapio_ativo.cardapio_combos.where(combo_id: combo.id).last.preco.to_f}::#{combo.imagem.url}::#{combo.combo_produto_ids.join(',')}::#{combo.combo_tipo_produto_ids.join(',')}..."
      end

      render json: { status: 200, saldo_disponivel: user.saldo_diario_atual, p: @produtos_cardapio_string, c: @combos_cardapio_string }
    else
      render json: { status: "NEGADO" }
    end
  end

  def get_produtos

    cardapio_ativo = Cardapio.where(escola_id: params[:e], ativo: true).last

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


    @produtos_cardapio = Produto.where(id: cardapio_produto_ids)
    @combos_cardapio = Combo.where(id: cardapio_combo_ids)

    @produtos_cardapio_string = ""
    @produtos_cardapio.each do |produto|
      @produtos_cardapio_string += "#{produto.nome}::#{produto.id}::#{cardapio_ativo.cardapio_produtos.where(produto_id: produto.id).last.preco.to_f}::#{produto.quantidade}::#{produto.imagem.url}..."
    end
    
    @combos_cardapio_string = ""
    @combos_cardapio.each do |combo|
      @combos_cardapio_string += "#{combo.nome}::#{combo.id}::#{cardapio_ativo.cardapio_combos.where(combo_id: combo.id).last.preco.to_f}::#{combo.imagem.url}..."
    end

    render json: { status: 200, p: @produtos_cardapio_string, c: @combos_cardapio_string }

  end

  def authenticate_totem
    @equipamento = Equipamento.where(token: params[:t]).first if params[:t]

    render json: {}, status: 403 if !@equipamento
  end

  def aut_cross
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

end
