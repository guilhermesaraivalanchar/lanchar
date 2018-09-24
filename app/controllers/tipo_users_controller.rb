class TipoUsersController < ApplicationController
  def index
  	@tipo_users = TipoUser.all
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
      if @tipo_user.update_attributes(tipo_user_params)
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
      if @tipo_user.update_attributes(tipo_user_params)
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
      if @tipo_user.destroy
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
  end

  def init_current
    @tipo_user = TipoUser.find(params[:id])
  end
end
