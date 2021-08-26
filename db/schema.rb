# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_08_25_000719) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answer_cards", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "card_id", null: false
    t.integer "combo_num", null: false
    t.boolean "any_rank", null: false
    t.boolean "any_suit", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_id"], name: "index_answer_cards_on_card_id"
    t.index ["question_id"], name: "index_answer_cards_on_question_id"
  end

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.integer "minutes_to_read"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "board_cards", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "card_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_id"], name: "index_board_cards_on_card_id"
    t.index ["question_id"], name: "index_board_cards_on_question_id"
  end

  create_table "cards", force: :cascade do |t|
    t.integer "card_id"
    t.integer "rank_id"
    t.string "rank"
    t.string "suit"
  end

  create_table "games", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "num_questions"
    t.integer "num_right"
    t.integer "score"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_games_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "cards"
    t.string "user_choice"
    t.string "answer"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "game_id"
    t.integer "question_num"
    t.boolean "is_right"
  end

  create_table "user_choice_cards", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "card_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["card_id"], name: "index_user_choice_cards_on_card_id"
    t.index ["question_id"], name: "index_user_choice_cards_on_question_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "username"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "points", default: 200
    t.string "password_digest"
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

  add_foreign_key "answer_cards", "cards"
  add_foreign_key "answer_cards", "questions"
  add_foreign_key "articles", "users"
  add_foreign_key "board_cards", "cards"
  add_foreign_key "board_cards", "questions"
  add_foreign_key "games", "users"
  add_foreign_key "user_choice_cards", "cards"
  add_foreign_key "user_choice_cards", "questions"
end
