class ProdutosController < ApplicationController
  def index
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_produtos")
    @can_criar_produtos = current_user.tem_permissao("criar_produtos")
    @can_ver_produto = current_user.tem_permissao("ver_produto")
    @can_editar_produtos = current_user.tem_permissao("editar_produtos")
    @can_deletar_produtos = current_user.tem_permissao("deletar_produtos")
    @can_ativar_desativar_produtos = current_user.tem_permissao("ativar_desativar_produtos")
    
    @filtro = Filtro.where(user_id: current_user.id, local: "produto_index").first
    @filtro ||= Filtro.new(user_id: current_user.id)

    where_nome_filtro = ""
    where_nome_filtro = "produtos.nome LIKE '%#{@filtro.filtro_1.upcase}%'" if @filtro.filtro_1.present?
    where_codigo_filtro = ""
    where_codigo_filtro = "produtos.codigo LIKE '%#{@filtro.filtro_2}%'" if @filtro.filtro_2.present?
    where_tipo_filtro = ""
    where_tipo_filtro = "produtos.quantidade >= #{@filtro.filtro_3.to_i} AND produtos.quantidade <= #{@filtro.filtro_5.to_i}" if @filtro.filtro_3.present? && @filtro.filtro_5.present?
    where_tipo_filtro = "produtos.quantidade = #{@filtro.filtro_3.to_i}" if @filtro.filtro_3.present? && !@filtro.filtro_5.present?
    where_tipo_filtro = "produtos.quantidade = #{@filtro.filtro_5.to_i}" if !@filtro.filtro_3.present? && @filtro.filtro_5.present?

    if @filtro.filtro_4 == "0"
      @produtos = Produto.where(escola_id: current_user.escola_id).where(where_nome_filtro).where(where_codigo_filtro).where(where_tipo_filtro).where(ativo: false)
    elsif @filtro.filtro_4 == "1"
      @produtos = Produto.where(escola_id: current_user.escola_id).where(where_nome_filtro).where(where_codigo_filtro).where(where_tipo_filtro).where(ativo: true)
    elsif @filtro.filtro_4 == "2"
      @produtos = Produto.where(escola_id: current_user.escola_id).where(where_nome_filtro).where(where_codigo_filtro).where(where_tipo_filtro)
    else
      @produtos = Produto.where(escola_id: current_user.escola_id).where(where_nome_filtro).where(where_codigo_filtro).where(where_tipo_filtro).where(ativo: true)
    end
        

  end

  def show
    init_current

    sql = %Q{
      SELECT transferencias.id, transferencias.produto_id, transferencia_combos.produto_id as combo_produto_id, produto_transf.nome as produto_transf_nome, produto_combo_transf.nome as produto_combo_transf_nome, 
      transferencias.created_at as transf_created_at, transferencia_combos.created_at as transf_combo_created_at, comprador.nome as comprador_nome, vendedor_gerais.nome as vendedor_gerais_nome,
      vendedor_transf.nome as vendedor_transf_nome
      FROM transferencias 
      LEFT JOIN transferencia_combos ON transferencia_combos.transferencia_id = transferencias.id
      LEFT JOIN produtos AS produto_transf ON produto_transf.id = transferencias.produto_id
      LEFT JOIN produtos AS produto_combo_transf ON produto_combo_transf.id = transferencia_combos.produto_id
      LEFT JOIN transferencia_gerais ON transferencia_gerais.id = transferencias.transferencia_geral_id
      LEFT JOIN users AS comprador ON comprador.id = transferencia_gerais.user_id
      LEFT JOIN users AS vendedor_gerais ON vendedor_gerais.id = transferencia_gerais.user_movimentou_id
      LEFT JOIN users AS vendedor_transf ON vendedor_transf.id = transferencias.user_movimentou_id
      WHERE transferencias.produto_id = #{params[:id]} OR transferencia_combos.produto_id = #{params[:id]}
    }

    @transferencias_produtos = Transferencia.find_by_sql [sql]


  end

  def edit
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("editar_produtos")
    init_current

    if @produto.imagem_file_name != nil
      @imagem = @produto.imagem.url.split("?")
      @produto_imagem = @imagem[0]
    end
  end

  def new
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("criar_produtos")
    init_new
  end

  def create
    init_new
    produto_params[:nome] = produto_params[:nome].upcase
    produto_params[:escola_id] = current_user.escola_id
    produto_params[:ativo] = true
    respond_to do |format|
      if current_user.tem_permissao("criar_produtos") && @produto.update_attributes(produto_params)
        format.html { redirect_to(produtos_path, :notice => "Produto criado com sucesso.") }
      else
        format.html do
          render :action => "edit"
        end
      end
    end
  end

  def update
    init_current
    produto_params[:nome] = produto_params[:nome].upcase
    respond_to do |format|
      if current_user.tem_permissao("editar_produtos") && @produto.update_attributes(produto_params)
        format.html { redirect_to(produtos_path, :notice => "Produto editado com sucesso.") }
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
      if current_user.tem_permissao("deletar_produtos") && @produto.destroy
        format.html { redirect_to(produtos_path, :notice => "Produto apagado com sucesso.") }
      else
        format.html { redirect_to(produtos_path, :notice => "Ocorreu um erro ao apagar o produto.") }
      end
    end
  end

  def desativar_ativar_produto

    produto = Produto.find(params[:produto_id])
    resp = ""
    if produto.ativo
      resp = "desativo"
      produto.update_attribute(:ativo, false)
    else
      resp = "ativo"
      produto.update_attribute(:ativo, true)
    end

    render json:  { resultado: resp }

  end

  def produtos_vendidos


    produtos = []    

    @data_inicio = "#{Time.now.in_time_zone.strftime("%Y-%m-%d")} 00:00:00"
    @data_fim = "#{Time.now.in_time_zone.strftime("%Y-%m-%d")} 23:59:59"
    
    if params[:data_inicio].present? && params[:data_fim].present?

      @data_inicio = params[:data_inicio].to_time.in_time_zone.strftime("%Y-%m-%d %H:%M") rescue @data_inicio
      @data_fim = params[:data_fim].to_time.in_time_zone.strftime("%Y-%m-%d %H:%M") rescue @data_fim

    end

    sql = %Q{
      SELECT produto_transf.nome as produto_transf_nome, produto_combo_transf.nome as produto_combo_transf_nome, transferencias.created_at
      FROM transferencias 
      LEFT JOIN transferencia_combos ON transferencia_combos.transferencia_id = transferencias.id
      LEFT JOIN produtos AS produto_transf ON produto_transf.id = transferencias.produto_id
      LEFT JOIN produtos AS produto_combo_transf ON produto_combo_transf.id = transferencia_combos.produto_id
      WHERE transferencias.tipo = "VENDA" OR transferencias.tipo = "VENDA_DIRETA"
    }

    @transferencias_produtos = Transferencia.find_by_sql [sql]

    @transferencias_produtos.each do |prod|

      produtos << {nome: prod[:produto_transf_nome] ? prod[:produto_transf_nome] : prod[:produto_combo_transf_nome], c: prod[:created_at] } if prod[:created_at] > @data_inicio.to_time  && prod[:created_at] < @data_fim.to_time 

    end

    @produtos_group = produtos.group_by { |d| d[:nome] }

  end

private
  def produto_params
    params.require(:produto).permit!
  end

  def init_new
    @produto = Produto.new()
    @tipo_produtos = TipoProduto.where(escola_id: current_user.escola_id).collect { |m| [m.nome, m.id] }
  end

  def init_current
    @produto = Produto.find(params[:id])
    @tipo_produtos = TipoProduto.where(escola_id: current_user.escola_id).collect { |m| [m.nome, m.id] }
  end
end
