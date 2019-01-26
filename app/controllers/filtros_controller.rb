class FiltrosController < ApplicationController

  def salvar_filtro

    filtro = Filtro.where(local: params[:filtro_local], user_id: current_user.id).last
    filtro = Filtro.new(local: params[:filtro_local], user_id: current_user.id) if !filtro

    filtro.filtro_1 = params[:filtro_1] if params[:filtro_1]
    filtro.filtro_2 = params[:filtro_2] if params[:filtro_2]
    filtro.filtro_3 = params[:filtro_3] if params[:filtro_3]
    filtro.filtro_4 = params[:filtro_4] if params[:filtro_4]
    filtro.filtro_5 = params[:filtro_5] if params[:filtro_5]
    filtro.filtro_6 = params[:filtro_6] if params[:filtro_6]
    filtro.filtro_7 = params[:filtro_7] if params[:filtro_7]
    filtro.filtro_8 = params[:filtro_8] if params[:filtro_8]
    filtro.filtro_9 = params[:filtro_9] if params[:filtro_9]
    filtro.filtro_10 = params[:filtro_10] if params[:filtro_10]
  
    if filtro.save
      render json: { status: "salvo" }
    else
      render json: { status: "erro" }
    end

  end

end
