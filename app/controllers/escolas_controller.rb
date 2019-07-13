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

    sql = %Q{
      SELECT transferencia_gerais.created_at, transferencia_gerais.tipo
      FROM transferencia_gerais
      WHERE (transferencia_gerais.tipo = 'VENDA' OR transferencia_gerais.tipo = 'VENDA_DIRETA' OR transferencia_gerais.tipo = 'ENTRADA')
      AND transferencia_gerais.cancelada IS NULL
      AND transferencia_gerais.created_at > '2019-01-01 00:00:00'
    }

    @transferencias = TransferenciaGeral.find_by_sql [sql]

    transferencia_vendas = []
    transferencia_entrada = []

    @transferencias.each do |transferencia|
      transferencia_vendas << { mes: transferencia[:created_at].strftime("%m") } if transferencia[:tipo] == "VENDA" || transferencia[:tipo] == "VENDA_DIRETA" 
      transferencia_entrada << { mes: transferencia[:created_at].strftime("%m") } if transferencia[:tipo] == "ENTRADA"
    end

    vendas_group = transferencia_vendas.group_by { |d| d[:mes] }
    entradas_group = transferencia_entrada.group_by { |d| d[:mes] }

    @mes_padrao = ["01","02","03","04","05","06","07","08","09","10","11","12"]
    @venda_quantidades = [0,0,0,0,0,0,0,0,0,0,0,0]
    @entrada_quantidades = [0,0,0,0,0,0,0,0,0,0,0,0]

    mes_atual = Time.now.strftime("%m")

    vendas_group.each do |mes, tranfs|
      @venda_quantidades[mes.to_i - 1] = tranfs.count
    end

    entradas_group.each do |mes, tranfs|
      @entrada_quantidades[mes.to_i - 1] = tranfs.count
    end





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

    @dados_dias = []
    @dados_valor = []

    @dados = ActiveRecord::Base.connection.select_all(sql)

    @dados.each do |object|
      puts "

          #{object["Year"]}
          #{object["Month"]}
          #{object["Day"]}
          #{object["transf"]}



      "

      @dados_dias << "#{object["Day"]}/#{object["Month"]}"
      @dados_valor << "#{object["transf"]}"
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
