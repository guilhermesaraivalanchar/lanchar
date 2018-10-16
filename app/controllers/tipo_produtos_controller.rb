class TipoProdutosController < ApplicationController
  def index
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_tipo_produtos")
  	@tipo_produtos = TipoProduto.where(escola_id: current_user.escola_id)
  end

  def show
    init_current
  end

  def edit
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("editar_tipo_produtos")
    init_current
  end

  def new
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("criar_tipo_produtos")
    init_new
  end

  def create
    init_new
    tipo_produto_params[:escola_id] = current_user.escola_id
    respond_to do |format|
      if current_user.tem_permissao("criar_tipo_produtos") && @tipo_produto.update_attributes(tipo_produto_params)
        format.html { redirect_to(tipo_produtos_path, :notice => "Tipo Produto criado com sucesso.") }
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
      if current_user.tem_permissao("editar_tipo_produtos") && @tipo_produto.update_attributes(tipo_produto_params)
        format.html { redirect_to(tipo_produtos_path, :notice => "Tipo Produto editado com sucesso.") }
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
      if current_user.tem_permissao("deletar_tipo_produtos") && @tipo_produto.destroy
        format.html { redirect_to(tipo_produtos_path, :notice => "Tipo Produto apagado com sucesso.") }
      else
        format.html { redirect_to(tipo_produtos_path, :notice => "Ocorreu um erro ao apagar o Tipo Produto.") }
      end
    end
  end

private
  def tipo_produto_params
    params.require(:tipo_produto).permit!
  end

  def init_new
    @tipo_produto = TipoProduto.new()
  end

  def init_current
    @tipo_produto = TipoProduto.find(params[:id])
  end
end
