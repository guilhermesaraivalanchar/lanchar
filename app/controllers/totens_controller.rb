class TotensController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:login]
  
  def login
    user = User.where(escola_id: params[:e], codigo: params[:c]).first
    if user && user.valid_password?(params[:p])
      render json: { status: 200, saldo_disponivel: user.saldo_diario_atual }
    else
      render json: "", status: 403
    end
  end

  def authenticate_user
    @user ||= User.ativo.where(token_mobile: params[:token]).first if params[:token]

    render json: {}, status: 403 if !@user
  end

end
