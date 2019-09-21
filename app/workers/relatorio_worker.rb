class RelatorioWorker
  include Sidekiq::Worker

  def perform(relatorio_id)
    relatorio = Relatorio.find(relatorio_id)
    download = relatorio.user.downloads.create(path: relatorio.send(relatorio.nome))
    ApagarDownloadWorker.perform_in(1.minutes, download.id)
  end
end
