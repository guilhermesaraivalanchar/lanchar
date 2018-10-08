class ProdutosController < ApplicationController
  def index
  	@produtos = Produto.all
  end

  def show
    init_current
  end

  def edit
    init_current

    if @produto.imagem_file_name != nil
      @imagem = @produto.imagem.url.split("?")
      @produto_imagem = @imagem[0]
    end
  end

  def new
    init_new
  end

  def create
    init_new
    respond_to do |format|
      if current_user.tem_permissao("criar_usuarios") && @produto.update_attributes(produto_params)
        format.html { redirect_to(produtos_path, :notice => "Produto criado com sucesso.") }
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
      if current_user.tem_permissao("editar_usuarios") && @produto.update_attributes(produto_params)
        format.html { redirect_to(produtos_path, :notice => "Produto editado com sucesso.") }
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
      if current_user.tem_permissao("deletar_usuarios") && @produto.destroy
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

  def init_new
    @produto = Produto.new()
    @tipo_produtos = TipoProduto.all.collect { |m| [m.nome, m.id] }
  end

  def init_current
    @produto = Produto.find(params[:id])
    @tipo_produtos = TipoProduto.all.collect { |m| [m.nome, m.id] }
  end
end
