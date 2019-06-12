class CardapiosController < ApplicationController
  def index
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_cardapio")
  	@cardapios = Cardapio.where(escola_id: current_user.escola_id)
    @can_criar_cardapio = current_user.tem_permissao("criar_cardapio")
    @can_definir_cardapio = current_user.tem_permissao("definir_cardapio")
    @can_editar_cardapio = current_user.tem_permissao("editar_cardapio")
    @can_deletar_cardapio = current_user.tem_permissao("deletar_cardapio")
  end

  def show
    init_current
  end

  def edit
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("editar_cardapio")
    init_current
  end

  def new
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("criar_cardapio")
    init_new
  end

  def setar_cardapio
    if current_user.tem_permissao("definir_cardapio")

      cardapio = Cardapio.find(params[:cardapio_id])
      cardapio_atual = Cardapio.where(escola_id: current_user.escola_id, ativo: true).last

      cardapio_atual.update_attribute(:ativo, false) if cardapio_atual
      cardapio.update_attribute(:ativo, true)

      render json: { status: "OK"}
    else
      render json: { status: "NEGADO"}
    end
  end

  def create
    init_new
    cardapio_params[:escola_id] = current_user.escola_id
    respond_to do |format|
      if current_user.tem_permissao("criar_cardapio") && @cardapio.update_attributes(cardapio_params)
        format.html { redirect_to(cardapios_path, :notice => "Cardapio criado com sucesso.") }
      else
        format.html do
          render :action => "edit"
        end
      end
    end
  end

  def update
    init_current
    respond_to do |format|
      if current_user.tem_permissao("editar_cardapio") && @cardapio.update_attributes(cardapio_params)
        format.html { redirect_to(cardapios_path, :notice => "Cardapio editado com sucesso.") }
      else
        format.html do
          render :action => "edit"
        end
      end
    end
  end

  def destroy
    init_current
    respond_to do |format|
      if current_user.tem_permissao("deletar_cardapio") && @cardapio.destroy
        format.html { redirect_to(cardapios_path, :notice => "Cardapio apagado com sucesso.") }
      else
        format.html { redirect_to(cardapios_path, :notice => "Ocorreu um erro ao apagar o cardapio.") }
      end
    end
  end

  def preco_cardapio_combo
    cardapio = Cardapio.find(params[:cardapio_id])
    cardapio_combo = cardapio.cardapio_combos.where(combo_id: params[:combo_id]).first_or_initialize
    cardapio_combo.preco = params[:valor].to_d
    cardapio_combo.save

    render json: {status: "OK"}
  end

  def preco_cardapio_produto
    cardapio = Cardapio.find(params[:cardapio_id])
    cardapio_produto = cardapio.cardapio_produtos.where(produto_id: params[:produto_id]).first_or_initialize
    cardapio_produto.preco = params[:valor].to_d
    cardapio_produto.save

    render json: {status: "OK"}
  end

  def ativo_cardapio_combo
    cardapio = Cardapio.find(params[:cardapio_id])

    if params[:valor].present?
      cardapio_combo = cardapio.cardapio_combos.where(combo_id: params[:combo_id]).first
      cardapio_combo.preco = params[:valor]
      cardapio_combo.ativo = params[:ativo]
      cardapio_combo.save
    end

    render json: {status: "OK"}
  end

  def ativo_cardapio_produto

    puts "#{params.inspect}"

    cardapio = Cardapio.find(params[:cardapio_id])

    if params[:valor].present?
      cardapio_produto = cardapio.cardapio_produtos.where(produto_id: params[:produto_id]).first
      cardapio_produto.preco = params[:valor]
      cardapio_produto.ativo = params[:ativo]
      cardapio_produto.save
    end

    render json: {status: "OK"}
  end

  def cardapio_pais
    @cardapio = Cardapio.where(escola_id: current_user.escola_id, ativo: true).last
    prod_ids =  @cardapio.cardapio_produtos.map(&:produto_id)
    @produtos = Produto.where(id: prod_ids)
  end

private
  def cardapio_params
    params.require(:cardapio).permit!
  end

  def init_new
    @cardapio = Cardapio.new()
    @produtos = Produto.where(escola_id: current_user.escola_id).collect { |m| [m.nome, m.id] }
    @combos = Combo.where(escola_id: current_user.escola_id).collect { |m| [m.nome, m.id] }
  end

  def init_current
    @cardapio = Cardapio.find(params[:id])
    @produtos = Produto.where(escola_id: current_user.escola_id).collect { |m| [m.nome, m.id] }
    @combos = Combo.where(escola_id: current_user.escola_id).collect { |m| [m.nome, m.id] }
  end
end
