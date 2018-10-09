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


end
