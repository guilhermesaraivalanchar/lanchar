class EscolasController < ApplicationController
  def index
  end

  def show
    @escola = Escola.find(params[:id])
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_escola") || current_user.escola_id != @escola.id
    
  end
end
