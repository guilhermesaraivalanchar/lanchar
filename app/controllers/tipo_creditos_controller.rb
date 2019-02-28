class TipoCreditosController < ApplicationController
  def index
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_tipo_creditos")
  	@tipo_creditos = TipoCredito.where(escola_id: current_user.escola_id)
    @can_criar_tipo_creditos = current_user.tem_permissao("criar_tipo_creditos")
    @can_editar_tipo_creditos = current_user.tem_permissao("editar_tipo_creditos")
    @can_deletar_tipo_creditos = current_user.tem_permissao("deletar_tipo_creditos")
  end

  def show
    init_current
  end

  def edit
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("editar_tipo_creditos")
    init_current
  end

  def new
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("criar_tipo_creditos")
    init_new
  end

  def create
    init_new
    tipo_credito_params[:escola_id] = current_user.escola_id
    respond_to do |format|
      if current_user.tem_permissao("criar_tipo_creditos") && @tipo_credito.update_attributes(tipo_credito_params)
        format.html { redirect_to(tipo_creditos_path, :notice => "Tipo Credito criado com sucesso.") }
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
      if current_user.tem_permissao("editar_tipo_creditos") && @tipo_credito.update_attributes(tipo_credito_params)
        format.html { redirect_to(tipo_creditos_path, :notice => "Tipo Credito editado com sucesso.") }
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
      if current_user.tem_permissao("deletar_tipo_creditos") && @tipo_credito.destroy
        format.html { redirect_to(tipo_creditos_path, :notice => "Tipo Credito apagado com sucesso.") }
      else
        format.html { redirect_to(tipo_creditos_path, :notice => "Ocorreu um erro ao apagar o Tipo Credito.") }
      end
    end
  end

private
  def tipo_credito_params
    params.require(:tipo_credito).permit!
  end

  def init_new
    @tipo_credito = TipoCredito.new()
  end

  def init_current
    @tipo_credito = TipoCredito.find(params[:id])
  end
end
