class ApagarDownloadWorker
  include Sidekiq::Worker

  def perform(download_id)
  	download = Download.find(download_id)
  	path = "#{Rails.root}/public/relatorios/#{download.path}"
  	download.update_attribute(:apagado, true) if system("rm #{path}")
  end
end
