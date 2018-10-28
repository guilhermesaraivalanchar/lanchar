class TipoUsersController < ApplicationController
  def index
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_tipo_usuarios")
  	@tipo_users = TipoUser.where(escola_id: current_user.escola_id)
    @can_criar_tipo_usuarios = current_user.tem_permissao("criar_tipo_usuarios")
    @can_editar_tipo_usuarios = current_user.tem_permissao("editar_tipo_usuarios")
    @can_deletar_tipo_usuarios = current_user.tem_permissao("deletar_tipo_usuarios")
  end

  def show
    init_current
  end

  def edit
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("editar_tipo_usuarios")
    init_current
  end

  def new
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("criar_tipo_usuarios")
    init_new
  end

  def create
    init_new
    tipo_user_params[:escola_id] = current_user.escola_id
    respond_to do |format|
      if current_user.tem_permissao("criar_tipo_usuarios") && @tipo_user.update_attributes(tipo_user_params)
        format.html { redirect_to(tipo_users_path, :notice => "tipo_user criado com sucesso.") }
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
      if current_user.tem_permissao("editar_tipo_usuarios") && @tipo_user.update_attributes(tipo_user_params)
        format.html { redirect_to(tipo_users_path, :notice => "tipo_user editado com sucesso.") }
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
      if current_user.tem_permissao("deletar_tipo_usuarios") && @tipo_user.destroy
        format.html { redirect_to(tipo_users_path, :notice => "tipo_user apagado com sucesso.") }
      else
        format.html { redirect_to(tipo_users_path, :notice => "Ocorreu um erro ao apagar o tipo_user.") }
      end
    end
  end

private
  def tipo_user_params
    params.require(:tipo_user).permit!
  end

  def init_new
    @tipo_user = TipoUser.new()

    @permissoes = Permissao.all.group_by { |o| o.permissao_grupo }
  end

  def init_current
    @tipo_user = TipoUser.find(params[:id])
    @permissoes = Permissao.all.group_by { |o| o.permissao_grupo }
  end
end
