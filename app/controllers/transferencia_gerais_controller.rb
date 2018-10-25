class TransferenciaGeraisController < ApplicationController

	def transferencia_pdf

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

  def index
    @transferencia_gerais = TransferenciaGeral.all
  end

  def cancelar_transferencia
    @transferencia_geral = TransferenciaGeral.find(params[:id])
    

    respond_to do |format|
      if current_user.tem_permissao("cancelar_transacao") && @transferencia_geral.cancelar
        format.html { redirect_to(transferencia_gerais_path, :notice => "Transfenrecia cancelada com sucesso.") }
      else
        format.html { redirect_to(transferencia_gerais_path, :notice => "Ocorreu um erro ao apagar o produto.") }
      end
    end
  end
end
