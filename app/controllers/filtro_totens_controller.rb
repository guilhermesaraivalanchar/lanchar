class FiltroTotensController < ApplicationController
  def index
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_filtro_totem")
  	@filtro_totens = FiltroTotem.where(escola_id: current_user.escola_id)
    @can_criar_filtro_totem = current_user.tem_permissao("criar_filtro_totem")
    @can_editar_filtro_totem = current_user.tem_permissao("editar_filtro_totem")
    @can_deletar_filtro_totem = current_user.tem_permissao("deletar_filtro_totem")
  end


  def edit
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("editar_filtro_totem")
    init_current
  end

  def new
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("criar_filtro_totem")
    init_new
  end

  def create
    init_new
    filtro_totem_params[:enable_after_save] = true
    filtro_totem_params[:escola_id] = current_user.escola_id
    respond_to do |format|
      if current_user.tem_permissao("criar_filtro_totem") && @filtro_totem.update_attributes(filtro_totem_params)
        format.html { redirect_to(filtro_totens_path, :notice => "Filtro Totem criado com sucesso.") }
      else
        format.html do
          render :action => "edit"
        end
      end
    end
  end

  def update
    init_current
    filtro_totem_params[:enable_after_save] = true
    respond_to do |format|
      if current_user.tem_permissao("editar_filtro_totem") && @filtro_totem.update_attributes(filtro_totem_params)
        format.html { redirect_to(filtro_totens_path, :notice => "Filtro Totem editado com sucesso.") }
      else
        format.html do
          render :action => "edit"
        end
      end
    end
  end

  def destroy
    init_current
    respond_to do |format|
      if current_user.tem_permissao("deletar_filtro_totem") && @filtro_totem.destroy
        format.html { redirect_to(filtro_totens_path, :notice => "Filtro Totem apagado com sucesso.") }
      else
        format.html { redirect_to(filtro_totens_path, :notice => "Ocorreu um erro ao apagar o Filtro Totem.") }
      end
    end
  end
private
  def filtro_totem_params
    params.require(:filtro_totem).permit!
  end

  def init_new
    @filtro_totem = FiltroTotem.new()
    @filtro_totem_produtos = @filtro_totem.filtro_totem_produtos.map(&:produto_id)
  end

  def init_current
    @filtro_totem = FiltroTotem.find(params[:id])
    @filtro_totem_produtos = @filtro_totem.filtro_totem_produtos.map(&:produto_id)
  end
end

