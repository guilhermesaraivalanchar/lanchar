class TransferenciaGeraisController < ApplicationController

	def transferencia_pdf

    if !params[:totem].present?
      if !current_user.tem_permissao("comprar_sistema")
        redirect_to pagina_sem_permissao_path
        return false
      end
    end

    @transferencia_geral = TransferenciaGeral.find(params[:id])

    respond_to do |format|
      format.pdf do
        render  :pdf => "#{@transferencia_geral.id}",
                :show_as_html => params[:totem].present?,
                :margin => { :top                => 0,                         # default 10 (mm)
                             :bottom             => 0,
                             :left               => 0,
                             :right              => 0},
                :footer => {:right => "Página [page] de [topage]",
                            :font_name => "Courier", 
                            :font_size => "8"}
               
      end
    end 
  end

  def transferencia_completa_pdf

    if !current_user.tem_permissao("comprar_sistema")
      redirect_to pagina_sem_permissao_path
      return false
    end

    t_ids = params[:id].split(",")

    @transferencia_geral_all = TransferenciaGeral.where(id: t_ids)

    respond_to do |format|
      format.pdf do
        render  :pdf => "#{@transferencia_geral_all.last.id}",
                :show_as_html => params[:debug].present?,
                :margin => { :top                => 0,                         # default 10 (mm)
                             :bottom             => 0,
                             :left               => 0,
                             :right              => 0},
                :footer => {:right => "Página [page] de [topage]",
                            :font_name => "Courier", 
                            :font_size => "8"}
               
      end
    end 
  end

  def index
    @can_cancelar = current_user.tem_permissao("cancelar_transacao")

    @filtro = Filtro.where(user_id: current_user.id, local: "transferencia_gerais_index").first
    @filtro ||= Filtro.new(user_id: current_user.id)

    sql = %Q{
      SELECT transferencia_gerais.tipo, transferencia_gerais.id, transferencia_gerais.created_at, transferencia_gerais.valor, transferencia_gerais.cancelada, usuario_comprou.nome as usuario_comprou_nome, usuario_movimentou.nome as usuario_movimentou_nome, usuario_caixa.nome as usuario_caixa_nome
      FROM transferencia_gerais 
      LEFT JOIN users AS usuario_comprou ON usuario_comprou.id = transferencia_gerais.user_id
      LEFT JOIN users AS usuario_movimentou ON usuario_movimentou.id = transferencia_gerais.user_movimentou_id
      LEFT JOIN users AS usuario_caixa ON usuario_caixa.id = transferencia_gerais.user_caixa_id
      WHERE transferencia_gerais.escola_id = #{current_user.escola_id}
      AND transferencia_gerais.tipo IN ('VENDA','VENDA_DIRETA','ENTRADA','SAIDA', 'AJUSTE')
      AND transferencia_gerais.created_at > ? 
      AND transferencia_gerais.created_at < ?
      ORDER BY transferencia_gerais.created_at DESC
    }

    if @filtro.filtro_3.present? && @filtro.filtro_4.present?
      puts "TIME ! >> #{@filtro.filtro_3.to_datetime}"
      puts "TIME ! >> #{@filtro.filtro_4.to_datetime}"
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, @filtro.filtro_3.to_time.in_time_zone, @filtro.filtro_4.to_time.in_time_zone]
    elsif !params[:p] || params[:p] == "hoje"
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, "#{Time.now.at_beginning_of_day.in_time_zone.strftime("%Y-%m-%d")} 00:00:00}", "#{Time.now.at_end_of_day.in_time_zone.strftime("%Y-%m-%d")} 23:59:59}"]
    elsif params[:p] == "semana"
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, "#{Time.now.at_beginning_of_week.in_time_zone.strftime("%Y-%m-%d")} 00:00:00}", "#{Time.now.at_end_of_week.in_time_zone.strftime("%Y-%m-%d")} 23:59:59}"]
    elsif params[:p] == "mes"
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, "#{Time.now.at_beginning_of_month.in_time_zone.strftime("%Y-%m-%d")} 00:00:00}", "#{Time.now.at_end_of_month.in_time_zone.strftime("%Y-%m-%d")} 23:59:59}"]
    elsif params[:p] == "ano"
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, "#{Time.now.at_beginning_of_year.in_time_zone.strftime("%Y-%m-%d")} 00:00:00}", "#{Time.now.at_end_of_year.in_time_zone.strftime("%Y-%m-%d")} 23:59:59}"]
    elsif params[:p] == "todos"
      
      sql = %Q{
        SELECT transferencia_gerais.tipo, transferencia_gerais.id, transferencia_gerais.created_at, transferencia_gerais.valor, transferencia_gerais.cancelada, usuario_comprou.nome as usuario_comprou_nome, usuario_movimentou.nome as usuario_movimentou_nome, usuario_caixa.nome as usuario_caixa_nome
        FROM transferencia_gerais 
        LEFT JOIN users AS usuario_comprou ON usuario_comprou.id = transferencia_gerais.user_id
        LEFT JOIN users AS usuario_movimentou ON usuario_movimentou.id = transferencia_gerais.user_movimentou_id
        LEFT JOIN users AS usuario_caixa ON usuario_caixa.id = transferencia_gerais.user_caixa_id
        WHERE transferencia_gerais.escola_id = #{current_user.escola_id}
        AND transferencia_gerais.tipo IN ('VENDA','VENDA_DIRETA','ENTRADA','SAIDA', 'AJUSTE')
        ORDER BY transferencia_gerais.created_at DESC
      }

      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql]
    else
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, "#{Time.now.at_beginning_of_day.in_time_zone.strftime("%Y-%m-%d")} 00:00:00}", "#{Time.now.at_end_of_day.in_time_zone.strftime("%Y-%m-%d")} 23:59:59}"]
    end

      
  end

  def show
    @transferencia_geral = TransferenciaGeral.find(params[:id])
    @can_cancelar = current_user.tem_permissao("cancelar_transacao")
  end

  def cancelar_transferencia
    @transferencia_geral = TransferenciaGeral.find(params[:id])
    
    saida = @transferencia_geral.tipo == "SAIDA"
    venda = @transferencia_geral.tipo == "VENDA"

    caixa = current_user.caixa

    if (!caixa || (caixa && caixa.valor < @transferencia_geral.valor.to_d)) && !saida && !venda
      render json: { resultado: "CAIXA_SEM_VALOR_SUFICIENTE" }
    elsif current_user.tem_permissao("cancelar_transacao") && @transferencia_geral.cancelar(current_user)
      #format.html { redirect_to(transferencia_gerais_path, :notice => "Transfenrecia cancelada com sucesso.") }
      render json: { resultado: "OK"}
    else
      #format.html { redirect_to(transferencia_gerais_path, :notice => "Ocorreu um erro ao apagar o produto.") }
      render json: { resultado: "ERROR"}
    end
  end

  def cancelar_transferencia_unica
    transferencia = Transferencia.find(params[:id])

    caixa = current_user.caixa
    venda = transferencia.tipo == "VENDA"

    puts ""

    if (!caixa || (caixa && caixa.valor < transferencia.valor.to_d)) && !venda
      render json: { resultado: "CAIXA_SEM_VALOR_SUFICIENTE" }
    elsif current_user.tem_permissao("cancelar_transacao") && transferencia.cancelar(current_user)
      #format.html { redirect_to(transferencia_geral_path(transferencia.transferencia_geral.id), :notice => "Transfenrecia cancelada com sucesso.") }
      render json: { resultado: "OK"}
    else
      #format.html { redirect_to(transferencia_geral_path(transferencia.transferencia_geral.id), :notice => "Ocorreu um erro ao apagar o produto.") }
      render json: { resultado: "ERROR"}
    end
  end

  def segunda_via
    transf_id = User.find(params[:user_id]).transferencia_gerais.where(cancelada: [nil, false]).where(tipo: "VENDA").last.id rescue '0'
    render json: {resultado: "OK", transf_id: transf_id}
  end

end
