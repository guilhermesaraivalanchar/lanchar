class Escola < ApplicationRecord
  
  has_many :users, :dependent => :destroy
  has_many :produtos, :dependent => :destroy
  has_many :combos, :dependent => :destroy
  has_many :transferencia_gerais, :dependent => :destroy
  has_many :transferencias, :dependent => :destroy
  has_many :cardapios, :dependent => :destroy
  has_many :tipo_produtos, :dependent => :destroy
  has_many :tipo_users, :dependent => :destroy
  has_many :fornecedores, :dependent => :destroy
  has_many :equipamentos, :dependent => :destroy
  has_many :tipo_creditos, :dependent => :destroy
  has_many :caixas, :dependent => :destroy

  has_attached_file :logo, :styles => { :original => "900x900>" }
    do_not_validate_attachment_file_type :logo

  def saldo_devedor
    valor_vendido = self.transferencias.where("transferencias.valor > 0").where(tipo: ["VENDA", "VENDA_DIRETA"]).sum(:valor).to_d
    valor_reembolso = self.transferencias.where("transferencias.valor > 0").where(tipo: ["REEMBOLSO"]).sum(:valor).to_d
    valor = valor_vendido - valor_reembolso
    return valor * 0.02
  end

  def faturamento_diario
    self.transferencias.where("transferencias.created_at > ? AND transferencias.created_at < ? AND transferencias.valor > 0", "#{Time.now.in_time_zone.strftime("%Y-%m-%d")} 00:00:00", "#{Time.now.in_time_zone.strftime("%Y-%m-%d")} 23:59:59").where(cancelada: [nil, false], tipo: ["VENDA", "VENDA_DIRETA"]).sum(:valor)
  end

  def faturamento_mensal
    self.transferencia_gerais.where("transferencia_gerais.created_at > ? AND transferencia_gerais.created_at < ? AND transferencia_gerais.valor > 0" , inicio_mes, fim_mes).where(cancelada: [nil, false], tipo: ["VENDA", "VENDA_DIRETA"]).sum(:valor)
  end

  def saldo_em_caixa
    self.transferencias.where(tipo: ['ENTRADA','SAIDA','VENDA_DIRETA','SAIDA CANCELADA','DEPOSITO CANCELADO','REEMBOLSO_VENDA_DIRETA','AJUSTE','REEMBOLSO_VENDA_DIRETA_PRODUTO']).sum(&:valor)
  end

  def self.criar_escola(nome)
    escola = Escola.new(nome: nome, sem_credito: true)

    escola.tipo_users.new(nome: "Administrador", codigo: "admin", bloqueado: true, admin: true, protegido: true)
    escola.tipo_users.new(nome: "Aluno", codigo: "aluno", bloqueado: true, aluno: true, protegido: true)
    escola.tipo_users.new(nome: "Responsável", codigo: "responsavel", bloqueado: true, responsavel: true, protegido: true)
    escola.users.new(nome: "SISTEMA", email:"sistema_#{nome}@sistemacantinapro.com.br", codigo:"SISTEMA___#{nome}___1", password: 123456, sistema: true, saldo: 0)
    escola.users.new(nome: "Admin", email:"admin_#{nome}@sistemacantinapro.com.br", codigo:"admin", password: 123456, sistema: false, ativo: true, saldo: 0, admin: true)
    escola.tipo_produtos.new(nome: "Salgados")
    escola.tipo_produtos.new(nome: "Bebidas")
    escola.tipo_produtos.new(nome: "Outros")
    escola.tipo_creditos.new(tipo: "Dinheiro")
    escola.cardapios.new(nome: "Padrão", ativo: true)

    escola.save!

    puts escola.id
  end

  def inicio_dia
  end

  def fim_dia
  end

  def importar_alunos(atualizar)
    begin 
      grupo_aluno = TipoUser.where(escola_id: self.id, aluno: true).last
      grupo_responsavel = TipoUser.where(escola_id: self.id, responsavel: true).last
      alunos_ids = []
      nCodigoCliente = self.cliente_sponte
      sToken = self.token_sponte
      
      envio = HTTParty.post("http://api.sponteeducacional.net.br/WSAPIEdu.asmx/GetAlunos", 
        { body: { 
            nCodigoCliente: nCodigoCliente, 
            sToken: sToken,
            sParametrosBusca: "Situacao=-1"
          }, timeout: 600})

      # envio.parsed_response["ArrayOfWsAluno"].count

      erro = envio.parsed_response["ArrayOfWsAluno"]["wsAluno"]["RetornoOperacao"].to_s rescue ""

      if erro == "23 - Cliente não possui token cadastrado para acesso a WSAPIEdu, entre em contato com o suporte."
        return [500, "Cliente não possui token cadastrado para acesso"]
      elsif erro == "25 - Token Inválido."
        return [500, "Token Inválido"]
      else
        envio.parsed_response["ArrayOfWsAluno"]["wsAluno"].each do |retorno|

          user = User.where(codigo: retorno["NumeroMatricula"], escola_id: self.id).last
          if user
            alunos_ids << user.id
            if atualizar
              user.assign_attributes(nome: retorno["Nome"], email: "#{retorno["AlunoID"]}#{self.id}@nome.com", codigo: retorno["NumeroMatricula"], turma: retorno["TurmaAtual"], sponte: true, aluno_id_sponte: retorno["AlunoID"] )
              user = import_responsavel(user, retorno)
              user.save
            end
          else
            begin 
              nao_salvar = false
              u = User.new(nome: retorno["Nome"], email: "#{retorno["AlunoID"]}#{self.id}@nome.com", codigo: retorno["NumeroMatricula"], 
                turma: retorno["TurmaAtual"], sponte: true, saldo: 0, escola_id: self.id, ativo: true, credito: 30, senha_totem: "0000", password: "123456", 
                aluno_id_sponte: retorno["AlunoID"] )
              u.tipos_users.new(tipo_user_id: grupo_aluno.id)

              u = import_responsavel(u, retorno)

              u.save if !nao_salvar
            rescue Exception => error
              puts "



              #{error}


              #{error.backtrace}




              "
              raise ActiveRecord::Rollback
            end
          end
        end

        self.importar_responsaveis
        self.invalidar_alunos(alunos_ids)

        return [200, "OK"]
      end
    rescue Exception => error
      puts "



      #{error}


      #{error.backtrace}




      "
      raise ActiveRecord::Rollback
    end

  end

  def importar_responsaveis
    
    nCodigoCliente = self.cliente_sponte
    sToken = self.token_sponte

    envio = HTTParty.post("http://api.sponteeducacional.net.br/WSAPIEdu.asmx/GetResponsaveis", 
      { body: { 
          nCodigoCliente: nCodigoCliente, 
          sToken: sToken,
          sParametrosBusca: "Nome="
        }, timeout: 600})

    # envio.parsed_response["ArrayOfWsResponsavel"]["wsResponsavel"].count

    erro = envio.parsed_response["ArrayOfWsResponsavel"]["wsResponsavel"]["RetornoOperacao"].to_s rescue ""

    if erro == "23 - Cliente não possui token cadastrado para acesso a WSAPIEdu, entre em contato com o suporte."
      return [500, "Cliente não possui token cadastrado para acesso"]
    elsif erro == "25 - Token Inválido."
      return [500, "Token Inválido"]
    else
      envio.parsed_response["ArrayOfWsResponsavel"]["wsResponsavel"].each do |retorno|
        user = User.where(responsavel_sponte_id: retorno["ResponsavelID"], escola_id: self.id).last
        user.update_attribute(:codigo, retorno["CPFCNPJ"].get_only_digits) if user && retorno["CPFCNPJ"].present?
      end

      return [200, "OK"]
    end
    
  end

  def import_responsavel(u, retorno)

    grupo_responsavel = TipoUser.where(escola_id: self.id, responsavel: true).last
    multi_responsaveis = retorno["Responsaveis"]["wsResponsaveis"].first["Nome"] rescue nil

    if multi_responsaveis.present?

      retorno["Responsaveis"]["wsResponsaveis"].each do |responsavel|

        r = User.where(responsavel_sponte_id: responsavel["ResponsavelID"], escola_id: self.id).last

        if !r
          r = User.new(nome: responsavel["Nome"], email: "#{responsavel["ResponsavelID"]}#{self.id}r@nome.com", codigo: "#{responsavel["ResponsavelID"]}#{self.id}r", 
            sponte: true, saldo: 0, escola_id: self.id, ativo: true, credito: 30, senha_totem: "0000", password: "123456", 
            responsavel_sponte_id: responsavel["ResponsavelID"] )
          r.tipos_users.new(tipo_user_id: grupo_responsavel.id)
          r.save

          nao_salvar = !r.errors.empty?
        end

        u.responsavel_users.new(responsavel_id: r.id) if u.responsavel_users.where(responsavel_id: r.id).empty?
      end

    else
      responsavel = retorno["Responsaveis"]["wsResponsaveis"]
      r = User.where(responsavel_sponte_id: responsavel["ResponsavelID"], escola_id: self.id).last
      
      if !r
        r = User.new(nome: responsavel["Nome"], email: "#{responsavel["ResponsavelID"]}#{self.id}r@nome.com", codigo: "#{responsavel["ResponsavelID"]}#{self.id}r", 
          sponte: true, saldo: 0, escola_id: self.id, ativo: true, credito: 30, senha_totem: "0000", password: "123456", 
          responsavel_sponte_id: responsavel["ResponsavelID"] )
        r.tipos_users.new(tipo_user_id: grupo_responsavel.id)
        r.save
        nao_salvar = !r.errors.empty?
      end

      u.responsavel_users.new(responsavel_id: r.id) if u.responsavel_users.where(responsavel_id: r.id).empty?
    end

    return u

  end

  def invalidar_alunos(alunos_ids)
    ativos_atual = User.where(aluno: true, ativo: true, sponte: true, escola_id: self.id).map(&:id)
    ids_inativos = ativos_atual - alunos_ids
    User.where(id: ids_inativos).update_all(ativo: false)
  end

  def teste_importacao_sponte

    nCodigoCliente = self.cliente_sponte
    sToken = self.token_sponte
    envio = HTTParty.post("http://api.sponteeducacional.net.br/WSAPIEdu.asmx/GetAlunos", 
      { body: { 
          nCodigoCliente: nCodigoCliente, 
          sToken: sToken,
          sParametrosBusca: "Nome=1234567890123456789qwertyuiop"
        }, timeout: 600})

    resposta = envio.parsed_response["ArrayOfWsAluno"]["wsAluno"]["RetornoOperacao"].to_s rescue "ERRO"

    return "FALSE" if resposta == "ERRO"

    if envio.parsed_response["ArrayOfWsAluno"]["wsAluno"]["RetornoOperacao"].to_s == "23 - Cliente não possui token cadastrado para acesso a WSAPIEdu, entre em contato com o suporte."
      return "Cliente não possui token cadastrado para acesso"
    elsif envio.parsed_response["ArrayOfWsAluno"]["wsAluno"]["RetornoOperacao"].to_s == "25 - Token Inválido."
      return "Token Inválido"
    else
      return "OK"
    end

  end

  def teste_importacao

    nCodigoCliente = "45601"
    sToken = "RN5RrWWf8Pzh"
    envio = HTTParty.post("http://api.sponteeducacional.net.br/WSAPIEdu.asmx/GetAlunos", 
      { body: { 
          nCodigoCliente: nCodigoCliente, 
          sToken: sToken,
          sParametrosBusca: "Situacao=-1"
        }, timeout: 600})

    envio.parsed_response["ArrayOfWsAluno"]["wsAluno"].count



    nCodigoCliente = "45601"
    sToken = "RN5RrWWf8Pzh"
    envio = HTTParty.post("http://api.sponteeducacional.net.br/WSAPIEdu.asmx/GetResponsaveis", 
      { body: { 
          nCodigoCliente: nCodigoCliente, 
          sToken: sToken,
          sParametrosBusca: "Nome="
        }, timeout: 600})

    envio.parsed_response["ArrayOfWsResponsavel"]["wsResponsavel"].count



    envio = HTTParty.post("http://api.sponteeducacional.net.br/WSAPIEdu.asmx/GetSituacoesAlunos", 
      { body: { 
          nCodigoCliente: nCodigoCliente, 
          sToken: sToken
        }, timeout: 600})

    envio.parsed_response["ArrayOfWsAluno"]["wsAluno"].count



    envio = HTTParty.post("http://api.sponteeducacional.net.br/WSAPIEdu.asmx/GetCategorias", 
      { body: { 
          nCodigoCliente: nCodigoCliente, 
          sToken: sToken
        }, timeout: 600})

    envio.parsed_response["ArrayOfWsCategorias"]["wsCategorias"]["Categorias"]["Categorias"].count



    envio = HTTParty.post("http://api.sponteeducacional.net.br/WSAPIEdu.asmx/GetFormasCobrancas", 
      { body: { 
          nCodigoCliente: nCodigoCliente, 
          sToken: sToken
        }, timeout: 600})

    envio.parsed_response["ArrayOfWsFormasCobrancas"]["wsFormasCobrancas"]["FormasCobrancas"]["FormasCobrancas"].count

  end

  def self.atualizar_escolas
    Escola.where(integracao_diaria_sponte: true).where("token_sponte is not null and cliente_sponte is not null").each do |escola|
      IntegracaoSponteWorker.perform_async(escola.id, true) if escola.teste_importacao_sponte == "OK"
      sleep 5
    end
  end

  def self.atualizar_escolas_teste
    Escola.all.each do |e|
      if !e.teste_sc
        e.update_attribute(:teste_sc, 0)
      else
        e.update_attribute(:teste_sc, e.teste_sc+1)
      end
    end
  end


end
