class ProdutosController < ApplicationController
  def index
  	@produtos = Produto.all
  end

  def show
    @produto = Produto.find(params[:id])
  end

  def edit
    @produto = Produto.find(params[:id])

    if @produto.imagem_file_name != nil
      @imagem = @produto.imagem.url.split("?")
      @produto_imagem = @imagem[0]
    end
  end

  def new
    @produto = Produto.new()
  end

  def create
    @produto = Produto.new()
    respond_to do |format|
      if @produto.update_attributes(produto_params)
        format.html { redirect_to(produtos_path, :notice => "Produto criado com sucesso.") }
      else
        format.html do
          render :action => "edit"
        end
      end
    end
  end

  def update
    @produto = Produto.find(params[:id])
    respond_to do |format|
      if @produto.update_attributes(produto_params)
        format.html { redirect_to(produtos_path, :notice => "Produto editado com sucesso.") }
      else
        format.html do
          render :action => "edit"
        end
      end
    end
  end

  def destroy
    @produto = Produto.find(params[:id])
    respond_to do |format|
      if @produto.destroy
        format.html { redirect_to(produtos_path, :notice => "Produto apagado com sucesso.") }
      else
        format.html { redirect_to(produtos_path, :notice => "Ocorreu um erro ao apagar o produto.") }
      end
    end
  end

private
  def produto_params
    params.require(:produto).permit!
  end
end
