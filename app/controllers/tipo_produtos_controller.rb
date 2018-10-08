class TipoProdutosController < ApplicationController
  def index
  	@tipo_produtos = TipoProduto.all
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

  def create
    init_new
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
