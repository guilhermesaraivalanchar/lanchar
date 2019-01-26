class UsersController < ApplicationController
  def index
  	@users = User.where(escola_id: current_user.escola_id, sem_compra: [nil,false])
    @can_criar_usuarios = current_user.tem_permissao("criar_usuarios")
    @can_ver_usuario = current_user.tem_permissao("ver_usuario")
    @can_editar_usuarios = current_user.tem_permissao("editar_usuarios")
    @can_creditar_usuarios_tabela = current_user.tem_permissao("creditar_usuarios_tabela")
    @can_deletar_usuarios = current_user.tem_permissao("deletar_usuarios")
    @can_ativar_desativar_usuarios = current_user.tem_permissao("ativar_desativar_usuarios")

    @filtro = Filtro.where(user_id: current_user.id, local: "user_index").first
    @filtro ||= Filtro.new(user_id: current_user.id)

    @tipo_users = TipoUser.all.collect{|n| [n.nome,n.id]}
    
    where_nome_filtro = ""
    where_nome_filtro = "AND users.nome LIKE '%#{@filtro.filtro_1}%'" if @filtro.filtro_1.present?
    where_codigo_filtro = ""
    where_codigo_filtro = "AND users.codigo LIKE '%#{@filtro.filtro_2}%'" if @filtro.filtro_2.present?
    where_tipo_filtro = ""
    where_tipo_filtro = "AND tipo_users.id in (#{@filtro.filtro_3.split('||').join(',')})" if @filtro.filtro_3.present?
    where_ativo_filtro = true
    where_ativo_filtro = false if @filtro.filtro_4.present? && @filtro.filtro_4 == "0"

    sql = %Q{
      SELECT users.nome, users.id, users.codigo, users.nome, users.tipos, users.turma, users.saldo, users.credito, users.ativo
      FROM users 
      LEFT JOIN tipos_users on tipos_users.user_id == users.id
      LEFT JOIN tipo_users on tipo_users.id == tipos_users.tipo_user_id
      WHERE users.escola_id = #{current_user.escola_id} #{where_nome_filtro} #{where_codigo_filtro} #{where_tipo_filtro}
      AND users.ativo = ?
      AND (users.sem_compra is null or users.sem_compra = ?) 
    }

    @users = User.find_by_sql [sql, where_ativo_filtro, false]

  end

  def salvar_filtro_index

    filtro_user_index = FiltroDatatable.where(datatable_nome: "user_index", user_id: current_user.id).last

    if filtro_user_index
      salvo = filtro_user_index.update_attributes(filtro_1: params[:filtro_centros], visivel_dash: params[:filtro_visivel].downcase)
    else
      salvo = FiltroDatatable.create(user_id: current_user.id, datatable_nome: "user_index", filtro_1: params[:filtro_centros], visivel_dash: params[:filtro_visivel])
    end

    if salvo
      render json: { status: "salvo" }
    else
      render json: { status: "erro" }
    end

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

    sql = %Q{
      SELECT transferencias.produto_id, transferencias.created_at, transferencias.valor, transferencias.saldo_anterior, transferencias.combo_id, transferencias.tipo, combos.nome as combo_nome, 
      produto_transf.nome as produto_nome, transferencias.id as transferencia_id
      FROM transferencia_gerais 
      INNER JOIN transferencias ON transferencias.transferencia_geral_id = transferencia_gerais.id
      LEFT JOIN produtos AS produto_transf ON produto_transf.id = transferencias.produto_id
      LEFT JOIN combos ON combos.id = transferencias.combo_id
      WHERE transferencia_gerais.escola_id = #{current_user.escola_id}
      AND transferencia_gerais.user_id = #{@user.id}
      AND transferencia_gerais.created_at > ? 
      AND transferencia_gerais.created_at < ?
      ORDER BY transferencias.id ASC
    }

    if !params[:p] || params[:p] == "hoje"
      @transferencias_gerais_user = TransferenciaGeral.find_by_sql [sql, Time.now.at_beginning_of_day, Time.now.at_end_of_day]
    elsif params[:p] == "semana"
      @transferencias_gerais_user = TransferenciaGeral.find_by_sql [sql, Time.now.at_beginning_of_week, Time.now.at_end_of_week]
    elsif params[:p] == "mes"
      @transferencias_gerais_user = TransferenciaGeral.find_by_sql [sql, Time.now.at_beginning_of_month, Time.now.at_end_of_month]
    elsif params[:p] == "ano"
      @transferencias_gerais_user = TransferenciaGeral.find_by_sql [sql, Time.now.at_beginning_of_year, Time.now.at_end_of_year]
    elsif params[:p] == "todos"
      
      sql = %Q{
        SELECT transferencias.produto_id, transferencias.created_at, transferencias.valor, transferencias.saldo_anterior, transferencias.combo_id, transferencias.tipo, combos.nome as combo_nome, 
        produto_transf.nome as produto_nome, transferencias.id as transferencia_id
        FROM transferencia_gerais 
        INNER JOIN transferencias ON transferencias.transferencia_geral_id = transferencia_gerais.id
        LEFT JOIN produtos AS produto_transf ON produto_transf.id = transferencias.produto_id
        LEFT JOIN combos ON combos.id = transferencias.combo_id
        WHERE transferencia_gerais.escola_id = #{current_user.escola_id}
        AND transferencia_gerais.user_id = #{@user.id}
        ORDER BY transferencias.id ASC
      }
      
      @transferencias_gerais_user = TransferenciaGeral.find_by_sql [sql]
    else
      @transferencias_gerais_user = TransferenciaGeral.find_by_sql [sql, Time.now.at_beginning_of_day, Time.now.at_end_of_day]
    end
      
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
    @user.ativo = true
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
        saldo_ant = user.saldo
        if current_user.tem_permissao("creditar_usuarios_tabela") && user.update_attribute(:saldo, params[:valor].to_d + user.saldo)
            if params[:status] == "caixa"
              transf_geral = TransferenciaGeral.new(escola_id: current_user.escola_id, user_id: user.id, valor: params[:valor], tipo: "ENTRADA", tipo_entrada: params[:tipo], user_movimentou_id: current_user.id, saldo_anterior: saldo_ant.to_d + params[:valor].to_d)
              transf_geral.transferencias.new({
                escola_id: current_user.escola_id,
                user_movimentou_id: current_user.id,
                valor: params[:valor],
                tipo: "ENTRADA",
                saldo_anterior: saldo_ant.to_d + params[:valor].to_d
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

  def desativar_ativar
    user = User.find(params[:user_id])
    resp = ""
    if user.ativo
      resp = "desativo"
      user.update_attribute(:ativo, false)
    else
      resp = "ativo"
      user.update_attribute(:ativo, true)
    end

    render json:  { resultado: resp }

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
