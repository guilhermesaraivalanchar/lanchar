class ApplicationController < ActionController::Base
  def index
    if !current_user
      #redirect_to "http://www.rubyonrails.org"
      redirect_to new_user_session_path
    else

      sql = %Q{
        SELECT transferencias.produto_id, transferencias.created_at, transferencias.valor, transferencias.saldo_anterior, transferencias.combo_id, transferencias.tipo, combos.nome as combo_nome, 
        produto_transf.nome as produto_nome, transferencias.id as transferencia_id
        FROM transferencia_gerais 
        INNER JOIN transferencias ON transferencias.transferencia_geral_id = transferencia_gerais.id
        LEFT JOIN produtos AS produto_transf ON produto_transf.id = transferencias.produto_id
        LEFT JOIN combos ON combos.id = transferencias.combo_id
        WHERE transferencia_gerais.escola_id = #{current_user.escola_id}
        AND transferencia_gerais.user_id = #{current_user.id}
        AND transferencia_gerais.created_at > ? 
        AND transferencia_gerais.created_at < ?
        ORDER BY transferencia_gerais.id ASC
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
          AND transferencia_gerais.user_id = #{current_user.id}
          ORDER BY transferencia_gerais.id ASC
        }
        
        @transferencias_gerais_user = TransferenciaGeral.find_by_sql [sql]
      else
        @transferencias_gerais_user = TransferenciaGeral.find_by_sql [sql, Time.now.at_beginning_of_day, Time.now.at_end_of_day]
      end
      
      @cardapio = Cardapio.where(escola_id: current_user.escola_id, ativo: true).last
    end

  end

  def pagina_sem_permissao
  end
end
