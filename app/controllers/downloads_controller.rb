class DownloadsController < ApplicationController
  def index
  	@downloads = current_user.downloads.where(apagado: nil).order("created_at DESC")
  end
end
