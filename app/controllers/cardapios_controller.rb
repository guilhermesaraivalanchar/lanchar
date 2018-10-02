class CardapiosController < ApplicationController
  def index
  	@cardapios = Cardapio.all
  end

  def show
    init_current
  end

  def edit
    init_current
  end

  def new
    init_new
  end

  def setar_cardapio
    
    cardapio = Cardapio.find(params[:cardapio_id])
    cardapio_atual = Cardapio.where(ativo: true).last

    cardapio_atual.update_attribute(:ativo, false) if cardapio_atual
    cardapio.update_attribute(:ativo, true)

    render json: { status: "OK"}
  end

  def create
    init_new
    respond_to do |format|
      if @cardapio.update_attributes(cardapio_params)
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
      if @cardapio.update_attributes(cardapio_params)
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
      if @cardapio.destroy
        format.html { redirect_to(cardapios_path, :notice => "Cardapio apagado com sucesso.") }
      else
        format.html { redirect_to(cardapios_path, :notice => "Ocorreu um erro ao apagar o cardapio.") }
      end
    end
  end

private
  def cardapio_params
    params.require(:cardapio).permit!
  end

  def init_new
    @cardapio = Cardapio.new()
    @produtos = Produto.all.collect { |m| [m.nome, m.id] }
  end

  def init_current
    @cardapio = Cardapio.find(params[:id])
    @produtos = Produto.all.collect { |m| [m.nome, m.id] }
  end
end
