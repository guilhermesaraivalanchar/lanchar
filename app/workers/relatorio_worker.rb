class RelatorioWorker
  include Sidekiq::Worker

  def perform(relatorio_id)
    relatorio = Relatorio.find(relatorio_id)
    download = relatorio.user.downloads.create(path: relatorio.send(relatorio.nome), nome: relatorio.nome_arquivo)
    ApagarDownloadWorker.perform_in(12.hours, download.id)
  end
end
