class TesteWorker
  include Sidekiq::Worker

  def perform(valor)
    User.first.update_attribute(:saldo, valor.to_i)
  end
end
