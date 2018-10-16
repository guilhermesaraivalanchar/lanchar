class ProdutosController < ApplicationController
  def index
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_produtos")
    @produtos = Produto.where(escola_id: current_user.escola_id)
  end

  def show
    init_current
  end

  def edit
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("editar_produtos")
    init_current

    if @produto.imagem_file_name != nil
      @imagem = @produto.imagem.url.split("?")
      @produto_imagem = @imagem[0]
    end
  end

  def new
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("criar_produtos")
    init_new
  end

  def create
    init_new
    produto_params[:escola_id] = current_user.escola_id
    respond_to do |format|
      if current_user.tem_permissao("criar_produtos") && @produto.update_attributes(produto_params)
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
      if current_user.tem_permissao("editar_produtos") && @produto.update_attributes(produto_params)
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
      if current_user.tem_permissao("deletar_produtos") && @produto.destroy
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
    @tipo_produtos = TipoProduto.where(escola_id: current_user.escola_id).collect { |m| [m.nome, m.id] }
  end

  def init_current
    @produto = Produto.find(params[:id])
    @tipo_produtos = TipoProduto.where(escola_id: current_user.escola_id).collect { |m| [m.nome, m.id] }
  end
end
