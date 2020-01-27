class Relatorio < ApplicationRecord
  belongs_to :user

  after_save :gerar_relatorio

  def gerar_relatorio
    #Relatorio.delay.gerar_relatorio_delay(self.id)
    RelatorioWorker.perform_async(self.id)
  end

  def transferencias_gerais

    # data_inicio = "01/01/2017 00:00:00"
    # data_fim = "01/01/2020 15:00:00"
    current_user = self.user
    data_inicio = self.param_1
    data_fim = self.param_2
    users_movimentou = self.param_3.split("::") rescue nil
    #users = self.param_4.split("::") rescue nil
    tipos = self.param_5.split("::") rescue nil
    tipo_cancelados = self.param_6 rescue nil

    where_tipo = ""
    where_tipo = "AND transferencia_gerais.tipo IN ('#{tipos.join("','")}')" if !tipos.empty?

    where_cancelada = ""
    where_cancelada = "AND transferencia_gerais.cancelada is not null" if tipo_cancelados == "true"
    where_cancelada = "AND transferencia_gerais.cancelada is null" if tipo_cancelados == "false"

    where_user_movimentou = ""
    where_user_movimentou = "AND transferencia_gerais.user_movimentou_id IN (#{users_movimentou.join(",")})" if !users_movimentou.empty?

    sql = %Q{
      SELECT transferencia_gerais.tipo, transferencia_gerais.id, transferencia_gerais.created_at, transferencia_gerais.valor, transferencia_gerais.cancelada, usuario_comprou.nome as usuario_comprou_nome, 
      usuario_comprou.id as usuario_comprou_id, usuario_movimentou.nome as usuario_movimentou_nome, usuario_caixa.nome as usuario_caixa_nome, transferencia_gerais.tipo_entrada, tipo_creditos.tipo as tipo_credito_nome
      FROM transferencia_gerais 
      LEFT JOIN users AS usuario_comprou ON usuario_comprou.id = transferencia_gerais.user_id
      LEFT JOIN users AS usuario_movimentou ON usuario_movimentou.id = transferencia_gerais.user_movimentou_id
      LEFT JOIN users AS usuario_caixa ON usuario_caixa.id = transferencia_gerais.user_caixa_id
      LEFT JOIN tipo_creditos ON tipo_creditos.id = transferencia_gerais.tipo_credito_id
      WHERE transferencia_gerais.escola_id = #{current_user.escola_id}
      #{where_tipo}
      #{where_cancelada}
      #{where_user_movimentou}
      AND transferencia_gerais.created_at > '#{data_inicio.to_time.in_time_zone.strftime("%Y-%m-%d %H:%M")}'
      AND transferencia_gerais.created_at < '#{data_fim.to_time.in_time_zone.strftime("%Y-%m-%d %H:%M")}'
      ORDER BY transferencia_gerais.created_at DESC
    }

    @dados = ActiveRecord::Base.connection.select_all(sql)

    #gerar arquivo
    p = Axlsx::Package.new
    wb = p.workbook
    wb.add_worksheet(:name => "TransferenciaGeral") do |sheet|
      title = wb.styles.add_style :sz => 12, :b => true, alignment: {horizontal: :center}, :border => Axlsx::STYLE_THIN_BORDER
      merged = wb.styles.add_style :alignment => {horizontal: :center}, :border => Axlsx::STYLE_THIN_BORDER

      sheet.add_row ["ID", "Tipo", "Comprador", "Vendedor", "Caixa", "Tipo Crédito", "Data", "Mês", "Valor", "Cancelada"],  :style => title
      
      @dados.each do |object|
        sheet.add_row [
          object["id"], object["tipo"], object["usuario_comprou_nome"], object["usuario_movimentou_nome"], object["usuario_caixa_nome"], object["tipo_credito_nome"], object["created_at"].to_datetime.strftime("%d-%m-%Y_%H:%M:%S"), 
          I18n.t(object["created_at"].to_datetime.strftime("%B")), ActionController::Base.helpers.number_to_currency(object["valor"]), object["cancelada"]
        ],  :style => Axlsx::STYLE_THIN_BORDER
      end
    end

    p.use_shared_strings = true

    s = p.to_stream()
    file = File.open("#{Rails.root}/public/relatorios/transferencias_gerais_#{DateTime.now.strftime("%d-%m-%Y_%H:%M:%S")}.xlsx", 'w')
    file.write(s.read)
    file.close

    return File.basename(file.path)
  end

  def usuarios

    # "nome"
    # "codigo"
    # "turma"
    # "tipos"
    # "ativo"
    # "saldo
    # "credito"

    # param_1: string_tipo, 
    # param_2: $("#user_nome").val(), 
    # param_3: $("#user_codigo").val(), 
    # param_4: $("#saldo_inicio").val().replace("R$ ", ""), 
    # param_5: $("#saldo_fim").val().replace("R$ ", ""), 
    # param_6: $("#credito_inicio").val().replace("R$ ", ""), 
    # param_7: $("#credito_fim").val().replace("R$ ", "") 
    # param_8: $("#select_ativo").val() 

    tipos = self.param_1.split("::") rescue nil
    current_user = self.user

    where_tipo = ""
    where_tipo = "AND tipo_users.id IN ('#{tipos.join("','")}')" if !tipos.empty?

    where_ativo = ""
    if bba_env == "PROD"
      where_ativo = "AND users.ativo = TRUE" if self.param_8 == "true"
      where_ativo = "AND (users.ativo is null or users.ativo = FALSE)" if self.param_8 == "false"
    else
      where_ativo = "AND users.ativo = 1" if self.param_8 == "true"
      where_ativo = "AND (users.ativo is null or users.ativo = 0)" if self.param_8 == "false"
    end

    if bba_env == "PROD"
      where_admin_sistema = "AND (users.sistema is null or users.sistema = FALSE) AND (users.admin is null or users.admin = FALSE)"
    else
      where_admin_sistema = "AND (users.sistema is null or users.sistema = 0) AND (users.admin is null or users.admin = 0)"
    end

    where_nome = "AND users.nome LIKE '%#{self.param_2.upcase}%'" if self.param_2.present?
    where_codigo = "AND users.codigo LIKE '%#{self.param_3.upcase}%'" if self.param_3.present?

    where_saldo_maior = self.param_4.present? ? "AND users.saldo >= '#{self.param_4.to_f}'" : ""
    where_saldo_menor = self.param_5.present? ? "AND users.saldo <= '#{self.param_5.to_f}'" : ""
    where_credito_maior = self.param_6.present? ? "AND users.credito >= '#{self.param_6.to_f}'" : ""
    where_credito_menor = self.param_7.present? ? "AND users.credito <= '#{self.param_7.to_f}'" : ""

    sql = %Q{
      SELECT users.nome, users.codigo, users.saldo, users.credito, users.turma, users.tipos, users.ativo, users.cartao
      FROM  users
      LEFT JOIN tipos_users ON tipos_users.user_id = users.id
      LEFT JOIN tipo_users ON tipo_users.id = tipos_users.tipo_user_id
      WHERE users.escola_id = #{current_user.escola_id}
      #{where_admin_sistema}
      #{where_tipo}
      #{where_ativo}
      #{where_nome}
      #{where_codigo}
      #{where_saldo_maior}
      #{where_saldo_menor}
      #{where_credito_maior}
      #{where_credito_menor}
    }

    @dados = ActiveRecord::Base.connection.select_all(sql)

    #gerar arquivo
    p = Axlsx::Package.new
    wb = p.workbook
    wb.add_worksheet(:name => "TransferenciaGeral") do |sheet|
      title = wb.styles.add_style :sz => 12, :b => true, alignment: {horizontal: :center}, :border => Axlsx::STYLE_THIN_BORDER
      merged = wb.styles.add_style :alignment => {horizontal: :center}, :border => Axlsx::STYLE_THIN_BORDER

      sheet.add_row ["Nome", "Código", "Saldo", "Credito", "Turma", "Tipos", "Ativo", "Cartão"],  :style => title
      
      @dados.uniq.each do |object|
        sheet.add_row [
          object["nome"], 
          object["codigo"], 
          ActionController::Base.helpers.number_to_currency(object["saldo"]), 
          ActionController::Base.helpers.number_to_currency(object["credito"]), 
          object["turma"], 
          object["tipos"], 
          object["ativo"], 
          object["cartao"]
        ],  :style => Axlsx::STYLE_THIN_BORDER
      end
    end

    p.use_shared_strings = true

    s = p.to_stream()
    file = File.open("#{Rails.root}/public/relatorios/usuarios_#{DateTime.now.strftime("%d-%m-%Y_%H:%M:%S")}.xlsx", 'w')
    file.write(s.read)
    file.close

    return File.basename(file.path)
  end

end
