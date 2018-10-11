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

ActiveRecord::Schema.define(version: 2018_10_09_021027) do

  create_table "cardapio_combos", force: :cascade do |t|
    t.integer "combo_id"
    t.integer "cardapio_id"
    t.decimal "preco", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cardapio_produtos", force: :cascade do |t|
    t.integer "produto_id"
    t.integer "cardapio_id"
    t.decimal "preco", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

  create_table "escolas", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fornecedores", force: :cascade do |t|
    t.integer "codigo"
    t.string "nome"
    t.string "contato"
    t.string "email"
    t.string "telefone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "escola_id"
  end

  create_table "permissoes", force: :cascade do |t|
    t.string "permissao_nome"
    t.string "permissao_codigo"
    t.string "permissao_grupo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissoes_users", force: :cascade do |t|
    t.integer "tipo_user_id"
    t.integer "user_id"
    t.integer "permissao_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "produtos", force: :cascade do |t|
    t.integer "codigo"
    t.string "nome"
    t.integer "cod_desconto"
    t.integer "quantidade"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "escola_id"
    t.string "imagem_file_name"
    t.string "imagem_content_type"
    t.bigint "imagem_file_size"
    t.datetime "imagem_updated_at"
    t.integer "tipo_produto_id"
  end

  create_table "tipo_produtos", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tipo_users", force: :cascade do |t|
    t.string "nome"
    t.integer "desconto_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transferencia_combos", force: :cascade do |t|
    t.integer "transferencia_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "produto_id"
  end

  create_table "transferencia_gerais", force: :cascade do |t|
    t.integer "user_id"
    t.float "valor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transferencias", force: :cascade do |t|
    t.integer "user_movimentou_id"
    t.integer "produto_id"
    t.integer "combo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "transferencia_geral_id"
    t.float "valor"
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
    t.string "escola_id"
    t.string "imagem_file_name"
    t.string "imagem_content_type"
    t.integer "imagem_file_size"
    t.datetime "imagem_updated_at"
    t.string "tipo_user_id"
    t.decimal "saldo", precision: 10, scale: 2
    t.integer "usuario_responsavel_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end