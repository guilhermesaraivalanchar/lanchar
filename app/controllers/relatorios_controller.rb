class RelatoriosController < ApplicationController
  def index
  end

  def relatorio_transferencia

    if params[:busca] && params[:busca] == "false"

      @transferencia_gerais = []

    else
      where_tipo = ""
      if params[:tipo]
        params[:tipo].split(",").each do |tipo|
          where_tipo = where_tipo + "transferencia_gerais.tipo = '#{tipo.upcase}' or "
        end
      end
      where_tipo = where_tipo[0...-4]

      where_user_id = ""
      if params[:user_id]
        params[:user_id].split(",").each do |user_id|
          where_user_id = where_user_id + "transferencia_gerais.user_id = '#{user_id}' or "
        end
      end
      where_user_id = where_user_id[0...-4]

      where_cancelada = ""
      if params[:cancelada]
        if params[:cancelada] == 'true'
          where_cancelada = "transferencia_gerais.cancelada is not null"
        else
          where_cancelada = "transferencia_gerais.cancelada is null"
        end
      end


      if params[:data_inicio]
        if params[:data_fim]
          @transferencia_gerais = TransferenciaGeral.where(escola_id: current_user.escola_id).where("transferencia_gerais.created_at >= ? AND transferencia_gerais.created_at <= ?", params[:data_inicio].to_time.beginning_of_day, params[:data_fim].to_time.end_of_day).where(where_cancelada).where(where_tipo).where(where_user_id).order("created_at DESC")
        else
          @transferencia_gerais = TransferenciaGeral.where(escola_id: current_user.escola_id).where("transferencia_gerais.created_at >= ? AND transferencia_gerais.created_at <= ?", params[:data_inicio].to_time.beginning_of_day, params[:data_inicio].to_time.end_of_day).where(where_cancelada).where(where_tipo).where(where_user_id).order("created_at DESC")
        end
      else
        @transferencia_gerais = TransferenciaGeral.where(escola_id: current_user.escola_id).where(where_cancelada).where(where_tipo).where(where_user_id).order("created_at DESC")
      end
    end

  end

  def relatorio_usuario

    puts "


      User(nome: string, codigo: string, saldo: decimal, credito: integer, turma: string, saldo_diario: decimal, sem_compra: boolean, tipos: string)


    "

    if params[:busca] && params[:busca] == "false"

      @users = []

    else
      
      where_tipo_user = ""
      if params[:tipo_user_id]
        params[:tipo_user_id].split(",").each do |tipo_user_id|
          where_tipo_user = where_tipo_user + "tipos_users.tipo_user_id = '#{tipo_user_id.upcase}' or "
        end
      end
      where_tipo_user = where_tipo_user[0...-4]

      where_maior = ""
      if params[:maior]
        where_maior = "users.saldo >= '#{params[:maior]}'"
      end

      where_menor = ""
      if params[:menor]
        where_menor = "users.saldo <= '#{params[:menor]}'"
      end

      @users = User.joins("INNER JOIN tipos_users on tipos_users.user_id = users.id").where(where_tipo_user).where(where_maior).where(where_menor).uniq

      puts "


      #{@users.inspect}



      #{@users.map(&:id).inspect}







      "


    end

  end
end
