class EscolasController < ApplicationController
  def index
  end

  def show
    @escola = Escola.find(params[:id])
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_escola") || current_user.escola_id != @escola.id
    

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
      AND transferencia_gerais.tipo IN ('SAIDA CANCELADA','VENDA_DIRETA','ENTRADA','SAIDA')
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
        AND transferencia_gerais.tipo IN ('SAIDA CANCELADA','VENDA_DIRETA','ENTRADA','SAIDA')
        ORDER BY transferencia_gerais.created_at DESC
      }


      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql]
    else
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, Time.now.at_beginning_of_day, Time.now.at_end_of_day]
    end


  end

  def dash_vendas_entradas

    @dados = busca_transferencias(params)
    @dados_tipos = busca_transferencias_tipos(params)

    @dados_dias = []
    @dados_valor_entrada = []
    @dados_valor_saida = []
    @dados_valor_venda = []

    ano = params[:ano].present? ? params[:ano] : DateTime.now.strftime("%Y")
    mes = params[:mes].present? ? params[:mes] : DateTime.now.strftime("%m")

    dia_ini = "#{ano}-#{mes}-02".to_time.beginning_of_month
    dia_fim = "#{ano}-#{mes}-02".to_time.end_of_month


    (dia_ini.to_date..dia_fim.to_date).each do |data|
      @dados_dias << data.strftime("%d/%m")

      valor_entrada = @dados_tipos.select{|n| n["Day"].to_i == data.strftime("%d").to_i && n["Month"].to_i == data.strftime("%m").to_i && n["tipo"] == "ENTRADA"}.first["transf"] rescue 0
      valor_saida = @dados_tipos.select{|n| n["Day"].to_i == data.strftime("%d").to_i && n["Month"].to_i == data.strftime("%m").to_i && n["tipo"] == "SAIDA"}.first["transf"] rescue 0
      valor_dia_venda_normal = @dados_tipos.select{|n| n["Day"].to_i == data.strftime("%d").to_i && n["Month"].to_i == data.strftime("%m").to_i && n["tipo"] == "VENDA"}.first["transf"] rescue 0
      valor_dia_venda_direta = @dados_tipos.select{|n| n["Day"].to_i == data.strftime("%d").to_i && n["Month"].to_i == data.strftime("%m").to_i && n["tipo"] == "VENDA_DIRETA"}.first["transf"] rescue 0

      @dados_valor_entrada << valor_entrada
      @dados_valor_saida << valor_saida
      @dados_valor_venda << valor_dia_venda_normal + valor_dia_venda_direta
    end

    puts "


    DADOS

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

    base = "producao2"
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

    base = "producao2"
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
                    strftime('%d', created_at) AS "Day",
                    COUNT(*) AS "transf",
                    tipo
          FROM      transferencia_gerais
          WHERE transferencia_gerais.created_at > '#{data_inicio}'
          AND transferencia_gerais.created_at < '#{data_fim}'
          AND transferencia_gerais.escola_id = '#{current_user.escola_id}'
          GROUP BY  strftime('%d', created_at),
                    strftime('%m', created_at),
                    strftime('%Y', created_at),
                    tipo
          ORDER BY  "Year",
                    "Month",
                    "Day"

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
end
