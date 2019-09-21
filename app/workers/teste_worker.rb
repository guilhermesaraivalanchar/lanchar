class TesteWorker
  include Sidekiq::Worker

  def perform(relatorio_id)
    # User.first.update_attribute(:saldo, valor.to_i)
    relatorio = Relatorio.find(relatorio_id)
    user = relatorio.user.downloads.create(path: relatorio.send(relatorio.nome))
  end
end
