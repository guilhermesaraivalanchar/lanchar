class UsersController < ApplicationController
  def index
  	@users = User.where(escola_id: current_user.escola_id, sem_compra: [nil,false])
    @can_criar_usuarios = current_user.tem_permissao("criar_usuarios")
    @can_ver_usuario = current_user.tem_permissao("ver_usuario")
    @can_editar_usuarios = current_user.tem_permissao("editar_usuarios")
    @can_creditar_usuarios_tabela = current_user.tem_permissao("creditar_usuarios_tabela")
    @can_deletar_usuarios = current_user.tem_permissao("deletar_usuarios")
  end

  def index_responsavel
    @users = User.where(escola_id: current_user.escola_id, sem_compra: true)
    @can_criar_usuarios = current_user.tem_permissao("criar_usuarios")
    @can_ver_usuario = current_user.tem_permissao("ver_usuario")
    @can_editar_usuarios = current_user.tem_permissao("editar_usuarios")
    @can_creditar_usuarios_tabela = current_user.tem_permissao("creditar_usuarios_tabela")
    @can_deletar_usuarios = current_user.tem_permissao("deletar_usuarios")
  end

  def show
    init_current
    @user_responsavel = @user.responsavel_users.map(&:responsavel_id).include?(current_user.id)
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_usuario") && !@user_responsavel && current_user != @user
  end

  def edit
    init_current
    @user_responsavel = @user.responsavel_users.map(&:responsavel_id).include?(current_user.id)
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("editar_usuarios") && !@user_responsavel && current_user != @user

    if @user.imagem_file_name != nil
      @imagem = @user.imagem.url.split("?")
      @user_imagem = @imagem[0]
    end

    @produtos_bloqueados = @user.bloqueio_produtos.map(&:produto_id)

  end

  def resetar_senha
    u = User.find(params[:user_id])
    u.password = "123456"
    u.save
    render json: { status: "OK" }
  end

  def update
    init_current
    @user_responsavel = @user.responsavel_users.map(&:responsavel_id).include?(current_user.id)
    user_params[:enable_after_save] = true
    respond_to do |format|
      if (current_user.tem_permissao("editar_usuarios") || @user_responsavel) && @user.update_attributes(user_params)
        if !@user_responsavel
          format.html { redirect_to(users_path, :notice => "Usuário editado com sucesso.") }
        else
          format.html { redirect_to(user_path(@user.id), :notice => "Usuário editado com sucesso.") }
        end
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
    
    @produtos_bloqueados = @user.bloqueio_produtos.map(&:produto_id)
  end

  def create
    init_new 
    user_params[:escola_id] = current_user.escola_id
    @user.assign_attributes(user_params)
    @user.password = "123456"
    @user.email = "none#{@user.codigo}@none.com"
    @user.saldo = 0
    @user.credito = 30
    @user.enable_after_save = true
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
      transf_geral = TransferenciaGeral.new(escola_id: current_user.escola_id, valor: (params[:valor].to_d * -1), tipo: "SAIDA", user_movimentou_id: current_user.id, user_caixa_id: params[:user_caixa].to_i)
      transf_geral.transferencias.new({
        escola_id: current_user.escola_id,
        user_movimentou_id: current_user.id,
        valor: (params[:valor].to_d * -1),
        user_caixa_id: params[:user_caixa].to_i,
        tipo: "SAIDA"
      })
      
      transf_geral.save
      
      render json:  { resultado: "OK", transferencia_sangria: transf_geral.id }

    else
      user = User.find(params[:user_id])
      user.saldo = 0 if !user.saldo
      if user
        if current_user.tem_permissao("creditar_usuarios_tabela") && user.update_attribute(:saldo, params[:valor].to_d + user.saldo)
            if params[:status] == "caixa"
              transf_geral = TransferenciaGeral.new(escola_id: current_user.escola_id, user_id: user.id, valor: params[:valor], tipo: "ENTRADA", tipo_entrada: params[:tipo], user_movimentou_id: current_user.id)
              transf_geral.transferencias.new({
                escola_id: current_user.escola_id,
                user_movimentou_id: current_user.id,
                valor: params[:valor],
                tipo: "ENTRADA"
              })
              transf_geral.save
            end
            render json:  { resultado: "OK", transf_id: transf_geral.id }
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
