class CombosController < ApplicationController
  def index
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("ver_combos")
  	@combos = Combo.where(escola_id: current_user.escola_id)
    @can_criar_combos = current_user.tem_permissao("criar_combos")
    @can_editar_combos = current_user.tem_permissao("editar_combos")
    @can_deletar_combos = current_user.tem_permissao("deletar_combos")
  end

  def show
    init_current
  end

  def edit
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("editar_combos")
    init_current

    if @combo.imagem_file_name != nil
      @imagem = @combo.imagem.url.split("?")
      @combo_imagem = @imagem[0]
    end
  end

  def new
    redirect_to pagina_sem_permissao_path if !current_user.tem_permissao("criar_combos")
    init_new
  end

  def create
    init_new
    combo_params[:escola_id] = current_user.escola_id
    respond_to do |format|
      if current_user.tem_permissao("criar_combos") && @combo.update_attributes(combo_params)
        format.html { redirect_to(combos_path, :notice => "Combo criado com sucesso.") }
      else
        format.html do
          render :action => "edit"
        end
      end
    end
  end

  def update
    init_current
    respond_to do |format|
      if current_user.tem_permissao("editar_combos") && @combo.update_attributes(combo_params)
        format.html { redirect_to(combos_path, :notice => "Combo editado com sucesso.") }
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
      if current_user.tem_permissao("deletar_combos") && @combo.destroy
        format.html { redirect_to(combos_path, :notice => "Combo apagado com sucesso.") }
      else
        format.html { redirect_to(combos_path, :notice => "Ocorreu um erro ao apagar o combo.") }
      end
    end
  end

private
  def combo_params
    params.require(:combo).permit!
  end

  def init_new
    @combo = Combo.new()
  end

  def init_current
    @combo = Combo.find(params[:id])
  end
end
