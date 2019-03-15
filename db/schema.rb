# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_15_134527) do

  create_table "bloqueio_produtos", force: :cascade do |t|
    t.integer "produto_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["produto_id"], name: "index_bloqueio_produtos_on_produto_id"
    t.index ["user_id"], name: "index_bloqueio_produtos_on_user_id"
  end

  create_table "cardapio_combos", force: :cascade do |t|
    t.integer "combo_id"
    t.integer "cardapio_id"
    t.decimal "preco", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ativo"
  end

  create_table "cardapio_produtos", force: :cascade do |t|
    t.integer "produto_id"
    t.integer "cardapio_id"
    t.decimal "preco", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ativo"
  end

  create_table "cardapio_tipo_produtos", force: :cascade do |t|
    t.integer "tipo_produto_id"
    t.integer "cardapio_id"
    t.decimal "preco", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cardapios", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ativo"
    t.integer "escola_id"
    t.index ["escola_id"], name: "index_cardapios_on_escola_id"
  end

  create_table "combo_produtos", force: :cascade do |t|
    t.integer "produto_id"
    t.integer "combo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "combo_tipo_produtos", force: :cascade do |t|
    t.integer "tipo_produto_id"
    t.integer "combo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "combos", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "imagem_file_name"
    t.string "imagem_content_type"
    t.bigint "imagem_file_size"
    t.datetime "imagem_updated_at"
    t.integer "escola_id"
    t.index ["escola_id"], name: "index_combos_on_escola_id"
  end

  create_table "entrada_produtos", force: :cascade do |t|
    t.integer "fornecedor_id"
    t.integer "produto_id"
    t.decimal "preco_custo", precision: 10, scale: 2
    t.integer "quantidade"
    t.integer "escola_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_entrada_produtos_on_user_id"
  end

  create_table "equipamentos", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nome"
    t.integer "escola_id"
    t.index ["escola_id"], name: "index_equipamentos_on_escola_id"
  end

  create_table "escolas", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cor_fundo"
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.bigint "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "filtro_totem_produtos", force: :cascade do |t|
    t.integer "produto_id"
    t.integer "filtro_totem_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["filtro_totem_id"], name: "index_filtro_totem_produtos_on_filtro_totem_id"
    t.index ["produto_id"], name: "index_filtro_totem_produtos_on_produto_id"
  end

  create_table "filtro_totens", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "escola_id"
    t.index ["escola_id"], name: "index_filtro_totens_on_escola_id"
  end

  create_table "filtros", force: :cascade do |t|
    t.string "local"
    t.string "filtro_1"
    t.string "filtro_2"
    t.string "filtro_3"
    t.string "filtro_4"
    t.string "filtro_5"
    t.string "filtro_6"
    t.string "filtro_7"
    t.string "filtro_8"
    t.string "filtro_9"
    t.string "filtro_10"
    t.string "visiveis"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_filtros_on_user_id"
  end

  create_table "fornecedores", force: :cascade do |t|
    t.integer "codigo"
    t.string "nome"
    t.string "contato"
    t.string "email"
    t.string "telefone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "escola_id"
  end

  create_table "permissoes", force: :cascade do |t|
    t.string "permissao_nome"
    t.string "permissao_codigo"
    t.string "permissao_grupo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permissao_codigo"], name: "index_permissoes_on_permissao_codigo"
  end

  create_table "permissoes_users", force: :cascade do |t|
    t.integer "tipo_user_id"
    t.integer "user_id"
    t.integer "permissao_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permissao_id"], name: "index_permissoes_users_on_permissao_id"
    t.index ["tipo_user_id"], name: "index_permissoes_users_on_tipo_user_id"
    t.index ["user_id"], name: "index_permissoes_users_on_user_id"
  end

  create_table "produtos", force: :cascade do |t|
    t.integer "codigo"
    t.string "nome"
    t.integer "cod_desconto"
    t.integer "quantidade"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "imagem_file_name"
    t.string "imagem_content_type"
    t.integer "imagem_file_size"
    t.datetime "imagem_updated_at"
    t.integer "tipo_produto_id"
    t.integer "escola_id"
    t.boolean "ativo"
  end

  create_table "responsavel_users", force: :cascade do |t|
    t.integer "responsavel_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["responsavel_id"], name: "index_responsavel_users_on_responsavel_id"
    t.index ["user_id"], name: "index_responsavel_users_on_user_id"
  end

  create_table "tipo_creditos", force: :cascade do |t|
    t.integer "escola_id"
    t.string "tipo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tipo_produtos", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "escola_id"
    t.index ["escola_id"], name: "index_tipo_produtos_on_escola_id"
  end

  create_table "tipo_users", force: :cascade do |t|
    t.string "nome"
    t.integer "desconto_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "escola_id"
    t.index ["escola_id"], name: "index_tipo_users_on_escola_id"
  end

  create_table "tipos_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "tipo_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tipo_user_id"], name: "index_tipos_users_on_tipo_user_id"
    t.index ["user_id"], name: "index_tipos_users_on_user_id"
  end

  create_table "transferencia_combos", force: :cascade do |t|
    t.integer "transferencia_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "produto_id"
    t.boolean "cancelada"
    t.index ["transferencia_id"], name: "index_transferencia_combos_on_transferencia_id"
  end

  create_table "transferencia_gerais", force: :cascade do |t|
    t.integer "user_id"
    t.float "valor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "escola_id"
    t.string "tipo"
    t.string "tipo_entrada"
    t.boolean "cancelada"
    t.integer "user_movimentou_id"
    t.integer "user_caixa_id"
    t.decimal "saldo_anterior", precision: 10, scale: 2
    t.boolean "ig_saldo"
    t.integer "user_transferencia_saldo"
    t.index ["escola_id"], name: "index_transferencia_gerais_on_escola_id"
    t.index ["user_id"], name: "index_transferencia_gerais_on_user_id"
  end

  create_table "transferencias", force: :cascade do |t|
    t.integer "user_movimentou_id"
    t.integer "produto_id"
    t.integer "combo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "transferencia_geral_id"
    t.float "valor"
    t.integer "escola_id"
    t.string "tipo"
    t.boolean "cancelada"
    t.integer "user_caixa_id"
    t.decimal "saldo_anterior", precision: 10, scale: 2
    t.index ["combo_id"], name: "index_transferencias_on_combo_id"
    t.index ["escola_id"], name: "index_transferencias_on_escola_id"
    t.index ["produto_id"], name: "index_transferencias_on_produto_id"
    t.index ["transferencia_geral_id"], name: "index_transferencias_on_transferencia_geral_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: ""
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nome"
    t.string "codigo"
    t.string "desconto_id"
    t.string "cartao_id"
    t.string "imagem_file_name"
    t.string "imagem_content_type"
    t.integer "imagem_file_size"
    t.datetime "imagem_updated_at"
    t.decimal "saldo", precision: 10, scale: 2
    t.integer "escola_id"
    t.boolean "admin"
    t.integer "credito"
    t.string "turma"
    t.decimal "saldo_diario", precision: 10, scale: 2
    t.boolean "sem_compra"
    t.string "tipos"
    t.boolean "ativo"
    t.string "senha_totem"
    t.index ["codigo"], name: "index_users_on_codigo"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
