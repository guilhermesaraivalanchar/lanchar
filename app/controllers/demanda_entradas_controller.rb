class DemandaEntradasController < ApplicationController
  def new
  	@demanda_entrada = DemandaEntrada.new()
  end

  def create
    @demanda_entrada = DemandaEntrada.new()
    demanda_entradas_params[:escola_id] = current_user.escola_id
    respond_to do |format|
      if current_user.tem_permissao("dar_entrada_produto") && @demanda_entrada.update_attributes(demanda_entradas_params)
        format.html { redirect_to(entrada_produtos_path, :notice => "Entrada realizada com sucesso.") }
      else
        format.html do
          render :action => "edit"
        end
      end
    end
  end

private
  def demanda_entradas_params
    params.require(:demanda_entrada).permit!
  end
end
