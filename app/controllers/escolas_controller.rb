class EscolasController < ApplicationController
  def index
  end

  def show
    @escola = Escola.find(params[:id])
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_escola") || current_user.escola_id != @escola.id
    

    if @escola.logo_file_name != nil
      @logo = @escola.logo.url.split("?")
      @escola_imagem = @logo[0]
    end

  end

  def update
    @escola = Escola.find(params[:id])
    respond_to do |format|
      if current_user.tem_permissao("editar_escola") && @escola.update_attributes(escola_params)
        format.html { redirect_to(escola_path(@escola.id), :notice => "Escola editada com sucesso.") }
      else
        format.html do
          render :action => "edit"
        end
      end
    end
  end

  def mudar_cor_escola
    Escola.find(current_user.escola_id).update_attribute(:cor_fundo, params[:cor])

    render json: {resultado: "OK"}
  end

  def escola_hist_transacao

    @escola = current_user.escola

    sql = %Q{
      SELECT transferencia_gerais.tipo, transferencia_gerais.id, transferencia_gerais.created_at, transferencia_gerais.valor, transferencia_gerais.cancelada, usuario_comprou.nome as usuario_comprou_nome, 
      usuario_comprou.id as usuario_comprou_id, usuario_movimentou.nome as usuario_movimentou_nome, usuario_caixa.nome as usuario_caixa_nome, transferencia_gerais.tipo_entrada, tipo_creditos.tipo as tipo_credito_nome
      FROM transferencia_gerais 
      LEFT JOIN users AS usuario_comprou ON usuario_comprou.id = transferencia_gerais.user_id
      LEFT JOIN users AS usuario_movimentou ON usuario_movimentou.id = transferencia_gerais.user_movimentou_id
      LEFT JOIN users AS usuario_caixa ON usuario_caixa.id = transferencia_gerais.user_caixa_id
      LEFT JOIN tipo_creditos ON tipo_creditos.id = transferencia_gerais.tipo_credito_id
      WHERE transferencia_gerais.escola_id = #{current_user.escola_id}
      AND transferencia_gerais.tipo IN ('SAIDA CANCELADA','VENDA_DIRETA','ENTRADA','SAIDA','AJUSTE')
      AND transferencia_gerais.created_at > ? 
      AND transferencia_gerais.created_at < ?
      ORDER BY transferencia_gerais.created_at DESC
    }

    if !params[:p] || params[:p] == "hoje"
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, "#{Time.now.at_beginning_of_day.in_time_zone.strftime("%Y-%m-%d")} 00:00:00}", "#{Time.now.at_end_of_day.in_time_zone.strftime("%Y-%m-%d")} 23:59:59}"]
    elsif params[:p] == "semana"
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, "#{Time.now.at_beginning_of_week.in_time_zone.strftime("%Y-%m-%d")} 00:00:00}", "#{Time.now.at_end_of_week.in_time_zone.strftime("%Y-%m-%d")} 23:59:59}"]
    elsif params[:p] == "mes"
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, "#{Time.now.at_beginning_of_month.in_time_zone.strftime("%Y-%m-%d")} 00:00:00}", "#{Time.now.at_end_of_month.in_time_zone.strftime("%Y-%m-%d")} 23:59:59}"]
    elsif params[:p] == "ano"
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, "#{Time.now.at_beginning_of_year.in_time_zone.strftime("%Y-%m-%d")} 00:00:00}", "#{Time.now.at_end_of_year.in_time_zone.strftime("%Y-%m-%d")} 23:59:59}"]
    elsif params[:p] == "todos"
      
      sql = %Q{
        SELECT transferencia_gerais.tipo, transferencia_gerais.id, transferencia_gerais.created_at, transferencia_gerais.valor, transferencia_gerais.cancelada, usuario_comprou.nome as usuario_comprou_nome, 
        usuario_comprou.id as usuario_comprou_id, usuario_movimentou.nome as usuario_movimentou_nome, usuario_caixa.nome as usuario_caixa_nome, transferencia_gerais.tipo_entrada, tipo_creditos.tipo as tipo_credito_nome
        FROM transferencia_gerais 
        LEFT JOIN users AS usuario_comprou ON usuario_comprou.id = transferencia_gerais.user_id
        LEFT JOIN users AS usuario_movimentou ON usuario_movimentou.id = transferencia_gerais.user_movimentou_id
        LEFT JOIN users AS usuario_caixa ON usuario_caixa.id = transferencia_gerais.user_caixa_id
        LEFT JOIN tipo_creditos ON tipo_creditos.id = transferencia_gerais.tipo_credito_id
        WHERE transferencia_gerais.escola_id = #{current_user.escola_id}
        AND transferencia_gerais.tipo IN ('SAIDA CANCELADA','VENDA_DIRETA','ENTRADA','SAIDA','AJUSTE')
        ORDER BY transferencia_gerais.created_at DESC
      }


      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql]
    else
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, Time.now.at_beginning_of_day, Time.now.at_end_of_day]
    end


  end

  def dash_vendas_entradas

    #@dados = busca_transferencias(params)
    @dados_tipos = busca_transferencias_tipos(params)

    @dados_dias = []
    @dados_valor_entrada = []
    @dados_valor_saida = []
    @dados_valor_venda = []

    ano = params[:ano].present? ? params[:ano] : DateTime.now.strftime("%Y")
    mes = params[:mes].present? ? params[:mes] : DateTime.now.strftime("%m")

    dia_ini = "#{ano}-#{mes}-02".to_time.beginning_of_month
    dia_fim = "#{ano}-#{mes}-02".to_time.end_of_month

    (1..12).each do |mes|
      break if DateTime.now.strftime("%Y") == params[:ano] && mes > DateTime.now.strftime("%m").to_i

      valor_entrada = @dados_tipos.select{|n| n["Month"].to_i == mes && n["tipo"] == "ENTRADA"}.first["transf"] rescue 0
      valor_saida = @dados_tipos.select{|n| n["Month"].to_i == mes && n["tipo"] == "SAIDA"}.first["transf"] rescue 0
      valor_dia_venda_normal = @dados_tipos.select{|n| n["Month"].to_i == mes && n["tipo"] == "VENDA"}.first["transf"] rescue 0
      valor_dia_venda_direta = @dados_tipos.select{|n| n["Month"].to_i == mes && n["tipo"] == "VENDA_DIRETA"}.first["transf"] rescue 0

      @dados_dias << mes
      @dados_valor_entrada << valor_entrada
      @dados_valor_saida << valor_saida
      @dados_valor_venda << valor_dia_venda_normal + valor_dia_venda_direta
    end


    # (dia_ini.to_date..dia_fim.to_date).each do |data|
    #   @dados_dias << data.strftime("%d/%m")

    #   valor_entrada = @dados_tipos.select{|n| n["Day"].to_i == data.strftime("%d").to_i && n["Month"].to_i == data.strftime("%m").to_i && n["tipo"] == "ENTRADA"}.first["transf"] rescue 0
    #   valor_saida = @dados_tipos.select{|n| n["Day"].to_i == data.strftime("%d").to_i && n["Month"].to_i == data.strftime("%m").to_i && n["tipo"] == "SAIDA"}.first["transf"] rescue 0
    #   valor_dia_venda_normal = @dados_tipos.select{|n| n["Day"].to_i == data.strftime("%d").to_i && n["Month"].to_i == data.strftime("%m").to_i && n["tipo"] == "VENDA"}.first["transf"] rescue 0
    #   valor_dia_venda_direta = @dados_tipos.select{|n| n["Day"].to_i == data.strftime("%d").to_i && n["Month"].to_i == data.strftime("%m").to_i && n["tipo"] == "VENDA_DIRETA"}.first["transf"] rescue 0

    #   @dados_valor_entrada << valor_entrada
    #   @dados_valor_saida << valor_saida
    #   @dados_valor_venda << valor_dia_venda_normal + valor_dia_venda_direta
    # end

    puts "


    DADOS

    #{@dados_tipos.inspect}
    #{@dados_dias.inspect}
    #{@dados_valor_entrada.inspect}
    #{@dados_valor_saida.inspect}
    #{@dados_valor_venda.inspect}




    "


  end

  def busca_transferencias(params)
    ano = params[:ano].present? ? params[:ano] : DateTime.now.strftime("%Y")
    mes = params[:mes].present? ? params[:mes] : DateTime.now.strftime("%m")

    dia_ini = "#{ano}-#{mes}-02".to_time.beginning_of_month.strftime("%d")
    dia_fim = "#{ano}-#{mes}-02".to_time.end_of_month.strftime("%d")

    data_inicio = "#{ano}-#{mes}-#{dia_ini} 00:00:00"
    data_fim = "#{ano}-#{mes}-#{dia_fim} 23:59:59"

    base = "producao"
    if base == "producao"
      sql = %Q{
        SELECT    date_part('year', created_at) AS "Year",
                  date_part('month', created_at) AS "Month",
                  date_part('day', created_at) AS "Day",
                  COUNT(*) AS "transf"
        FROM      transferencia_gerais
        WHERE transferencia_gerais.created_at > '#{data_inicio}'
        AND transferencia_gerais.created_at < '#{data_fim}'
        AND transferencia_gerais.escola_id = '#{current_user.escola_id}'
        GROUP BY  date_part('day', created_at),
                  date_part('month', created_at),
                  date_part('year', created_at)
        ORDER BY  "Year",
                  "Month",
                  "Day"

      }
    else

      sql = %Q{
          SELECT    strftime('%Y', created_at) AS "Year",
                    strftime('%m', created_at) AS "Month",
                    strftime('%d', created_at) AS "Day",
                    COUNT(*) AS "transf"
          FROM      transferencia_gerais
          WHERE transferencia_gerais.created_at > '#{data_inicio}'
          AND transferencia_gerais.created_at < '#{data_fim}'
          AND transferencia_gerais.escola_id = '#{current_user.escola_id}'
          GROUP BY  strftime('%d', created_at),
                    strftime('%m', created_at),
                    strftime('%Y', created_at)
          ORDER BY  "Year",
                    "Month",
                    "Day"

      }
    end

    @dados = ActiveRecord::Base.connection.select_all(sql)

    return @dados

  end

  def busca_transferencias_tipos(params)

    ano = params[:ano].present? ? params[:ano] : DateTime.now.strftime("%Y")
    mes = params[:mes].present? ? params[:mes] : DateTime.now.strftime("%m")

    dia_ini = "#{ano}-#{mes}-02".to_time.beginning_of_month.strftime("%d")
    dia_fim = "#{ano}-#{mes}-02".to_time.end_of_month.strftime("%d")

    data_inicio = "#{ano}-#{mes}-#{dia_ini} 00:00:00"
    data_fim = "#{ano}-#{mes}-#{dia_fim} 23:59:59"

    data_inicio = "#{ano}-01-01 00:00:00"
    data_fim = "#{ano}-12-31 23:59:59"

    base = "producaoa"
    if base == "producao"
      sql = %Q{
        SELECT    date_part('year', created_at) AS "Year",
                  date_part('month', created_at) AS "Month",
                  date_part('day', created_at) AS "Day",
                  COUNT(*) AS "transf",
                  tipo
        FROM      transferencia_gerais
        WHERE transferencia_gerais.created_at > '#{data_inicio}'
        AND transferencia_gerais.created_at < '#{data_fim}'
        AND transferencia_gerais.escola_id = '#{current_user.escola_id}'
        GROUP BY  date_part('day', created_at),
                  date_part('month', created_at),
                  date_part('year', created_at),
                  tipo
        ORDER BY  "Year",
                  "Month",
                  "Day"

      }
    else

      sql = %Q{
          SELECT    strftime('%Y', created_at) AS "Year",
                    strftime('%m', created_at) AS "Month",
                    COUNT(*) AS "transf",
                    tipo
          FROM      transferencia_gerais
          GROUP BY  strftime('%m', created_at),
                    strftime('%Y', created_at),
                    tipo
          ORDER BY  "Year",
                    "Month"

      }




    end

    @dados = ActiveRecord::Base.connection.select_all(sql)

    return @dados

    @dados.each do |object|
      puts "
          #{object["Year"]}
          #{object["Month"]}
          #{object["Day"]}
          #{object["transf"]}
          #{object["tipo"]}
      "



    end


  end

  def desabilitar_saldo_diario

    escola = Escola.find(params[:escola_id])

    if params[:tipo] == "desabilitar_diario"

      escola.update_attribute(:desabilitar_diario, !escola.desabilitar_diario)

      render json: {status: "OK", escola_des_diario: escola.desabilitar_diario}
    elsif params[:tipo] == "itens_separados"

      escola.update_attribute(:itens_separados, !escola.itens_separados)

      render json: {status: "OK", escola_itens_separados: escola.itens_separados}
    elsif params[:tipo] == "sem_credito"

      escola.users.update_all(credito: 0) if !escola.sem_credito
      escola.update_attribute(:sem_credito, !escola.sem_credito)

      render json: {status: "OK", escola_sem_credito: escola.sem_credito}
    end
      
  end

  def resumo_caixa
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("resumo_caixa")

    @caixas = Caixa.all

    @transferencia_gerais_entrada_hoje = TransferenciaGeral.where(tipo: ["ENTRADA"], cancelada: [nil,false]).where('transferencia_gerais.caixa_id is not null').where("transferencia_gerais.created_at > ? AND transferencia_gerais.created_at < ? AND transferencia_gerais.valor > 0", Time.now.beginning_of_day.in_time_zone, Time.now.end_of_day.in_time_zone)
    @transferencia_gerais_venda_direta_hoje = TransferenciaGeral.where(tipo: ["VENDA_DIRETA"], cancelada: [nil,false]).where('transferencia_gerais.caixa_id is not null').where("transferencia_gerais.created_at > ? AND transferencia_gerais.created_at < ? AND transferencia_gerais.valor > 0", Time.now.beginning_of_day.in_time_zone, Time.now.end_of_day.in_time_zone)
    @transferencia_gerais_saida_hoje = TransferenciaGeral.where(tipo: "SAIDA", cancelada: [nil,false]).where("transferencia_gerais.created_at > ? AND transferencia_gerais.created_at < ?", Time.now.beginning_of_day.in_time_zone, Time.now.end_of_day.in_time_zone)
  end

  def resumo_escola
  end

  def get_resumo_escola

    inicio = params[:data_inicio].present? ? params[:data_inicio].to_time : Time.now
    fim = params[:data_fim].present? ? params[:data_fim].to_time : Time.now

    data_inicio = "#{inicio.strftime("%Y-%m-%d %H:%M:00")}"
    data_fim = "#{fim.strftime("%Y-%m-%d %H:%M:59")}"

    base = "producao"
    if base == "producao"
      sql = %Q{
        SELECT    date_part('year', created_at) AS "Year",
                  date_part('month', created_at) AS "Month",
                  date_part('day', created_at) AS "Day",
                  COUNT(*) AS "transf",
                  SUM(transferencias.valor) AS "valor",
                  tipo,
                  cancelada
        FROM      transferencias
        WHERE transferencias.created_at > '#{data_inicio}'
        AND transferencias.created_at < '#{data_fim}'
        AND transferencias.escola_id = '#{current_user.escola_id}'
        GROUP BY  date_part('day', created_at),
                  date_part('month', created_at),
                  date_part('year', created_at),
                  tipo,
                  cancelada
        ORDER BY  "Year",
                  "Month",
                  "Day"

      }
    else

      sql = %Q{
          SELECT    strftime('%Y', created_at) AS "Year",
                    strftime('%m', created_at) AS "Month",
                    strftime('%d', created_at) AS "Day",
                    COUNT(*) AS "transf",
                    SUM(transferencias.valor) AS "valor",
                    tipo,
                    cancelada
          FROM      transferencias
          WHERE transferencias.created_at > '#{data_inicio}'
          AND transferencias.created_at < '#{data_fim}'
          AND transferencias.escola_id = '#{current_user.escola_id}'
          GROUP BY  strftime('%d', created_at),
                    strftime('%m', created_at),
                    strftime('%Y', created_at),
                    tipo,
                    cancelada
          ORDER BY  "Year",
                    "Month",
                    "Day"

      }
    end

    @dados2 = ActiveRecord::Base.connection.select_all(sql)

    # @dados2.each do |object|
    #   puts "
    #       #{object["Year"]}
    #       #{object["Month"]}
    #       #{object["Day"]}
    #       #{object["transf"]}
    #       #{object["tipo"]}
    #       #{object["cancelada"]}
    #       #{object["valor"]}
    #   "

    # end

    entradas_totais = @dados2.select{|n| n["tipo"] == "ENTRADA"}
    sum_entradas_totais = entradas_totais.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30

    entradas = @dados2.select{|n| n["tipo"] == "ENTRADA" && !n["cancelada"].present?}
    sum_entradas = entradas.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30

    entradas_canceladas = @dados2.select{|n| n["tipo"] == "ENTRADA" && n["cancelada"].present?}
    sum_entradas_canceladas = entradas_canceladas.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30



    saidas_totais = @dados2.select{|n| n["tipo"] == "SAIDA"}
    sum_saidas_totais = saidas_totais.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30

    saidas = @dados2.select{|n| n["tipo"] == "SAIDA" && !n["cancelada"].present?}
    sum_saidas = saidas.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30

    saidas_canceladas = @dados2.select{|n| n["tipo"] == "SAIDA" && n["cancelada"].present?}
    sum_saidas_canceladas = saidas_canceladas.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30



    ajustes_totais = @dados2.select{|n| (n["tipo"] == "AJUSTE" )}
    sum_ajustes_totais = ajustes_totais.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30

    ajustes_positivos = @dados2.select{|n| (n["tipo"] == "AJUSTE" && n["valor"].to_d >= 0 )}
    sum_ajustes_positivos = ajustes_positivos.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30
    
    ajustes_negativos = @dados2.select{|n| (n["tipo"] == "AJUSTE" && n["valor"].to_d < 0 )}
    sum_ajustes_negativos = ajustes_negativos.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30
    

    vendas = @dados2.select{|n| n["tipo"] == "VENDA"}
    sum_vendas = @dados2.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30

    venda_diretas = @dados2.select{|n| n["tipo"] == "VENDA_DIRETA"}
    sum_venda_diretas = venda_diretas.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30




    vendas_totais = @dados2.select{|n| n["tipo"] == "VENDA"}
    sum_vendas_totais = vendas_totais.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30

    vendas = @dados2.select{|n| n["tipo"] == "VENDA" && !n["cancelada"].present?}
    sum_vendas = vendas.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30

    vendas_canceladas = @dados2.select{|n| n["tipo"] == "VENDA" && n["cancelada"].present?}
    sum_vendas_canceladas = vendas_canceladas.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30



    vendas_diretas_totais = @dados2.select{|n| n["tipo"] == "VENDA_DIRETA"}
    sum_vendas_diretas_totais = vendas_diretas_totais.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30

    vendas_diretas = @dados2.select{|n| n["tipo"] == "VENDA_DIRETA" && !n["cancelada"].present?}
    sum_vendas_diretas = vendas_diretas.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30

    vendas_diretas_canceladas = @dados2.select{|n| n["tipo"] == "VENDA_DIRETA" && n["cancelada"].present?}
    sum_vendas_diretas_canceladas = vendas_diretas_canceladas.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30







    venda_reembolso = @dados2.select{|n| (n["tipo"] == "REEMBOLSO" || n["tipo"] == "REEMBOLSO_PRODUTO")}
    sum_reembolso = venda_reembolso.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30

    venda_reembolso_vd = @dados2.select{|n| (n["tipo"] == "REEMBOLSO_VENDA_DIRETA" )}
    sum_venda_reembolso_vd = venda_reembolso_vd.inject(0) {|sum, hash| sum + hash["valor"].to_d} #=> 30

    puts "

      TRANSFERENCIAS

      entradas: #{entradas.count} - #{sum_entradas}
      entradas Totais: #{entradas_totais.count} - #{sum_entradas_totais}
      entradas Canceladas: #{entradas_canceladas.count} - #{sum_entradas_canceladas}
      entradas CONF: #{sum_entradas_totais - sum_entradas_canceladas}

      saidas: #{saidas.count} - #{sum_saidas}
      saidas Totais: #{saidas_totais.count} - #{sum_saidas_totais}
      saidas Canceladas: #{saidas_canceladas.count} - #{sum_saidas_canceladas}
      saidas CONF: #{sum_saidas_totais - sum_saidas_canceladas}

      ajustes Totais: #{ajustes_totais.count} - #{sum_ajustes_totais}
      ajustes Positivos: #{ajustes_positivos.count} - #{sum_ajustes_positivos}
      ajustes Negativos: #{ajustes_negativos.count} - #{sum_ajustes_negativos}
      ajustes CONF: #{sum_ajustes_positivos + sum_ajustes_negativos}



      vendas: #{vendas.count} - #{sum_vendas}
      vendas Totais: #{vendas_totais.count} - #{sum_vendas_totais}
      vendas Canceladas: #{vendas_canceladas.count} - #{sum_vendas_canceladas}
      vendas CONF: #{sum_vendas_totais - sum_vendas_canceladas}



      vendas_diretas: #{vendas_diretas.count} - #{sum_vendas_diretas}
      vendas_diretas Totais: #{vendas_diretas_totais.count} - #{sum_vendas_diretas_totais}
      vendas_diretas Canceladas: #{vendas_diretas_canceladas.count} - #{sum_vendas_diretas_canceladas}
      vendas_diretas CONF: #{sum_vendas_diretas_totais - sum_vendas_diretas_canceladas}


    "

    #ActionController::Base.helpers.number_to_currency(transferencia_geral[:valor])

    str_sum_entradas = ActionController::Base.helpers.number_to_currency(sum_entradas)
    str_sum_entradas_totais = ActionController::Base.helpers.number_to_currency(sum_entradas_totais)
    str_sum_entradas_canceladas = ActionController::Base.helpers.number_to_currency(sum_entradas_canceladas)
    str_sum_saidas = ActionController::Base.helpers.number_to_currency(sum_saidas*-1)
    str_sum_saidas_totais = ActionController::Base.helpers.number_to_currency(sum_saidas_totais*-1)
    str_sum_saidas_canceladas = ActionController::Base.helpers.number_to_currency(sum_saidas_canceladas*-1)
    str_sum_ajustes_totais = ActionController::Base.helpers.number_to_currency(sum_ajustes_totais)
    str_sum_ajustes_positivos = ActionController::Base.helpers.number_to_currency(sum_ajustes_positivos)
    str_sum_ajustes_negativos = ActionController::Base.helpers.number_to_currency(sum_ajustes_negativos)
    str_sum_vendas = ActionController::Base.helpers.number_to_currency(sum_vendas)
    str_sum_vendas_totais = ActionController::Base.helpers.number_to_currency(sum_vendas_totais)
    str_sum_vendas_canceladas = ActionController::Base.helpers.number_to_currency(sum_vendas_canceladas)
    str_sum_vendas_diretas = ActionController::Base.helpers.number_to_currency(sum_vendas_diretas)
    str_sum_vendas_diretas_totais = ActionController::Base.helpers.number_to_currency(sum_vendas_diretas_totais)
    str_sum_vendas_diretas_canceladas = ActionController::Base.helpers.number_to_currency(sum_vendas_diretas_canceladas)
    str_faturamento = ActionController::Base.helpers.number_to_currency(sum_vendas + sum_vendas_diretas)

    render json: { 
      entradas: str_sum_entradas, entradas_totais: str_sum_entradas_totais, entradas_canceladas: str_sum_entradas_canceladas, saidas: str_sum_saidas, saidas_totais: str_sum_saidas_totais, 
      saidas_canceladas: str_sum_saidas_canceladas, ajustes_totais: str_sum_ajustes_totais, ajustes_positivos: str_sum_ajustes_positivos, ajustes_negativos: str_sum_ajustes_negativos,
      vendas: str_sum_vendas, vendas_totais: str_sum_vendas_totais, vendas_canceladas: str_sum_vendas_canceladas, vendas_diretas: str_sum_vendas_diretas, vendas_diretas_totais: str_sum_vendas_diretas_totais, 
      vendas_diretas_canceladas: str_sum_vendas_diretas_canceladas, faturamento: str_faturamento
    }


  end

  def ajuste_saldo
    puts "



    "

    caixa = current_user.caixa

    if (!caixa && params[:valor].to_d < 0) || (caixa && caixa.valor < params[:valor].to_d*(-1))
      render json: { resultado: "CAIXA_SEM_VALOR_SUFICIENTE" }
    else
      tf = TransferenciaGeral.new(user_id: current_user.id, valor: params[:valor].to_d, escola_id: current_user.escola_id, tipo: "AJUSTE", user_movimentou_id: current_user.id)
      tf.transferencias.new(user_movimentou_id: current_user.id, valor: params[:valor].to_d, escola_id: current_user.escola_id, tipo:"AJUSTE" )
      tf.save

      puts tf.inspect

      if tf.errors.empty?
        render json: { resultado: "OK" }
      else
        render json: { resultado: "ERROR" }
      end
    end

    puts "




    "

  end

private
  def escola_params
    params.require(:escola).permit!
  end

end
