class EntradaProdutosController < ApplicationController
  def index
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_fornecedores")
  end

  def new
    @entrada_produto = EntradaProduto.new()
  end

  def show
    init_current
  end

  def create
    @entrada_produto = EntradaProduto.new()
    entrada_produtos_params[:escola_id] = current_user.escola_id
    respond_to do |format|
      if current_user.tem_permissao("dar_entrada_produto") && @entrada_produto.update_attributes(entrada_produtos_params)
        @entrada_produto.produto.update_attribute(:quantidade,@entrada_produto.produto.quantidade + @entrada_produto.quantidade)
        format.html { redirect_to(produtos_path, :notice => "Entrada realizada com sucesso.") }
      else
        format.html do
          render :action => "edit"
        end
      end
    end
  end

private
  def entrada_produtos_params
    params.require(:entrada_produto).permit!
  end
end
