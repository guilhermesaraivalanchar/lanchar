class TransferenciaGeraisController < ApplicationController

	def transferencia_pdf

    if !current_user.tem_permissao("comprar_sistema")
      redirect_to pagina_sem_permissao_path
      return false
    end

    @transferencia_geral = TransferenciaGeral.find(params[:id])

    respond_to do |format|
      format.pdf do
        render  :pdf => "#{@transferencia_geral.id}",
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
    @transferencia_gerais = TransferenciaGeral.where("transferencia_gerais.created_at > ? AND transferencia_gerais.created_at < ? AND transferencia_gerais.valor > 0", Time.now.beginning_of_day, Time.now.end_of_day).where(tipo: ["VENDA","VENDA_DIRETA","ENTRADA","SAIDA"], escola_id: current_user.escola_id).order("created_at DESC")
  end

  def cancelar_transferencia
    @transferencia_geral = TransferenciaGeral.find(params[:id])
    

    respond_to do |format|
      if current_user.tem_permissao("cancelar_transacao") && @transferencia_geral.cancelar(current_user)
        format.html { redirect_to(transferencia_gerais_path, :notice => "Transfenrecia cancelada com sucesso.") }
      else
        format.html { redirect_to(transferencia_gerais_path, :notice => "Ocorreu um erro ao apagar o produto.") }
      end
    end
  end
end
