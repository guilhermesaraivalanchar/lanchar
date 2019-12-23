class IntegracaoSponteWorker
  include Sidekiq::Worker

  def perform(escola_id, att)
  	Escola.find(escola_id).importar_alunos(att)
  end

end
