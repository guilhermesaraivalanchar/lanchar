class FornecedoresController < ApplicationController
  def index
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_fornecedores")
    @fornecedores = Fornecedor.where(escola_id: current_user.escola_id)
    @can_criar_fornecedores = current_user.tem_permissao("criar_fornecedores")
	@can_editar_fornecedores = current_user.tem_permissao("editar_fornecedores")
	@can_deletar_fornecedores = current_user.tem_permissao("deletar_fornecedores")
  end

  def show
    init_current
  end

  def edit
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("editar_fornecedores")
    init_current
  end

  def new
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("criar_fornecedores")
    init_new
  end

  def create
    init_new
    fornecedor_params[:escola_id] = current_user.escola_id
    respond_to do |format|
      if current_user.tem_permissao("criar_fornecedores") && @fornecedor.update_attributes(fornecedor_params)
        format.html { redirect_to(fornecedores_path, :notice => "fornecedor criado com sucesso.") }
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
      if current_user.tem_permissao("editar_fornecedores") && @fornecedor.update_attributes(fornecedor_params)
        format.html { redirect_to(fornecedores_path, :notice => "fornecedor editado com sucesso.") }
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
      if current_user.tem_permissao("deletar_fornecedores") && @fornecedor.destroy
        format.html { redirect_to(fornecedores_path, :notice => "fornecedor apagado com sucesso.") }
      else
        format.html { redirect_to(fornecedores_path, :notice => "Ocorreu um erro ao apagar o fornecedor.") }
      end
    end
  end

private
  def fornecedor_params
    params.require(:fornecedor).permit!
  end

  def init_new
    @fornecedor = Fornecedor.new()
  end

  def init_current
    @fornecedor = Fornecedor.find(params[:id])
  end
end
