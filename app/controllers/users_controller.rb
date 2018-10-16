class UsersController < ApplicationController
  def index
  	@users = User.where(escola_id: current_user.escola_id)
  end

  def show
    init_current
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_usuario") && current_user.id != @user.usuario_responsavel_id && current_user != @user
  end

  def edit
    init_current
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("editar_usuarios") && current_user.id != @user.usuario_responsavel_id && current_user != @user

    if @user.imagem_file_name != nil
      @imagem = @user.imagem.url.split("?")
      @user_imagem = @imagem[0]
    end

  end

  def update
    init_current
    respond_to do |format|
      if current_user.tem_permissao("editar_usuarios") && @user.update_attributes(user_params)
        format.html { redirect_to(users_path, :notice => "Usuário editado com sucesso.") }
      else
        format.html do
          render :action => "edit"
        end
      end
    end
  end

  def new
    init_new
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("criar_usuarios")
  end

  def create
    init_new 
    user_params[:escola_id] = current_user.escola_id
    @user.assign_attributes(user_params)
    @user.password = "123456"
    @user.email = "none#{@user.codigo}@none.com"
    @user.saldo = 0
    respond_to do |format|
      if current_user.tem_permissao("criar_usuarios") && @user.save
        format.html { redirect_to(users_path, :notice => "Usuário criado com sucesso.") }
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
      if current_user.tem_permissao("deletar_usuarios") && @user.destroy 
        format.html { redirect_to(users_path, :notice => "Usuário apagado com sucesso.") }
      else
        format.html { redirect_to(users_path, :notice => "Ocorreu um erro ao apagar o usuário.") }
      end
    end
  end

  def creditar

    if params[:status] == "sangria"
      transf_geral = TransferenciaGeral.new(escola_id: current_user.escola_id, valor: (params[:valor].to_d * -1), tipo: "SAIDA")
      transf_geral.transferencias.new({
        escola_id: current_user.escola_id,
        user_movimentou_id: current_user.id,
        valor: (params[:valor].to_d * -1),
        tipo: "SAIDA"
      })
      
      transf_geral.save
      
      render json:  { resultado: "OK" }

    else
      user = User.find(params[:user_id])
      user.saldo = 0 if !user.saldo
      if user
        if current_user.tem_permissao("creditar_usuarios_tabela") && user.update_attribute(:saldo, params[:valor].to_d + user.saldo)
            if params[:status] == "caixa"
              transf_geral = TransferenciaGeral.new(escola_id: current_user.escola_id, user_id: user.id, valor: params[:valor], tipo: "ENTRADA", tipo_entrada: params[:tipo])
              transf_geral.transferencias.new({
                escola_id: current_user.escola_id,
                user_movimentou_id: current_user.id,
                valor: params[:valor],
                tipo: "ENTRADA"
              })
              transf_geral.save
            end
            render json:  { resultado: "OK" }
          else
            render json:  { resultado: "ERRO_ADD" }
          end
      else
        render json:  { resultado: "USU_INEXISTENTE" }
      end
    end


  end

private
  def user_params
    params.require(:user).permit!
  end

  def init_vars
    @tipo_users = TipoUser.where(escola_id: current_user.escola_id).collect { |m| [m.nome, m.id] }
    @users = User.where(escola_id: current_user.escola_id).collect { |m| [m.nome, m.id] }
  end

  def init_new
    @user = User.new()
    init_vars
  end

  def init_current
    @user = User.find(params[:id])
    init_vars
  end
end
