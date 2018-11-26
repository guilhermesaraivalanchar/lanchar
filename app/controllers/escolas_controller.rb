class EscolasController < ApplicationController
  def index
  end

  def show
    @escola = Escola.find(params[:id])
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_escola") || current_user.escola_id != @escola.id
    

    sql = %Q{
      SELECT transferencia_gerais.tipo, transferencia_gerais.id, transferencia_gerais.created_at, transferencia_gerais.valor, transferencia_gerais.cancelada, usuario_comprou.nome as usuario_comprou_nome, 
      usuario_comprou.id as usuario_comprou_id, usuario_movimentou.nome as usuario_movimentou_nome, usuario_caixa.nome as usuario_caixa_nome, transferencia_gerais.tipo_entrada
      FROM transferencia_gerais 
      LEFT JOIN users AS usuario_comprou ON usuario_comprou.id = transferencia_gerais.user_id
      LEFT JOIN users AS usuario_movimentou ON usuario_movimentou.id = transferencia_gerais.user_movimentou_id
      LEFT JOIN users AS usuario_caixa ON usuario_caixa.id = transferencia_gerais.user_caixa_id
      WHERE transferencia_gerais.escola_id = #{current_user.escola_id}
      AND transferencia_gerais.tipo IN ('SAIDA CANCELADA','VENDA_DIRETA','ENTRADA','SAIDA')
      AND transferencia_gerais.created_at > ? 
      AND transferencia_gerais.created_at < ?
      ORDER BY transferencia_gerais.created_at DESC
    }

    if !params[:p] || params[:p] == "hoje"
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, Time.now.at_beginning_of_day, Time.now.at_end_of_day]
    elsif params[:p] == "semana"
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, Time.now.at_beginning_of_week, Time.now.at_end_of_week]
    elsif params[:p] == "mes"
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, Time.now.at_beginning_of_month, Time.now.at_end_of_month]
    elsif params[:p] == "ano"
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, Time.now.at_beginning_of_year, Time.now.at_end_of_year]
    elsif params[:p] == "todos"
      
      sql = %Q{
        SELECT transferencia_gerais.tipo, transferencia_gerais.id, transferencia_gerais.created_at, transferencia_gerais.valor, transferencia_gerais.cancelada, usuario_comprou.nome as usuario_comprou_nome, 
        usuario_comprou.id as usuario_comprou_id, usuario_movimentou.nome as usuario_movimentou_nome, usuario_caixa.nome as usuario_caixa_nome, transferencia_gerais.tipo_entrada
        FROM transferencia_gerais 
        LEFT JOIN users AS usuario_comprou ON usuario_comprou.id = transferencia_gerais.user_id
        LEFT JOIN users AS usuario_movimentou ON usuario_movimentou.id = transferencia_gerais.user_movimentou_id
        LEFT JOIN users AS usuario_caixa ON usuario_caixa.id = transferencia_gerais.user_caixa_id
        WHERE transferencia_gerais.escola_id = 1
        AND transferencia_gerais.tipo IN ('SAIDA CANCELADA','VENDA_DIRETA','ENTRADA','SAIDA')
        ORDER BY transferencia_gerais.created_at DESC
      }


      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql]
    else
      @transferencia_gerais = TransferenciaGeral.find_by_sql [sql, Time.now.at_beginning_of_day, Time.now.at_end_of_day]
    end


  end
end
