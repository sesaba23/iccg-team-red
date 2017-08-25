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

ActiveRecord::Schema.define(version: 20170825164349) do

  create_table "documents", force: :cascade do |t|
    t.string "doc_type"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games", force: :cascade do |t|
    t.string "current_question"
    t.string "current_questioner"
    t.string "current_reader_answer"
    t.string "current_guesser_answer"
    t.string "current_judged_suspicious"
    t.string "state"
    t.integer "coin_flip"
    t.integer "guesser_score"
    t.integer "reader_score"
    t.integer "judge_score"
    t.integer "document_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_games_on_document_id"
  end

  create_table "guessers", force: :cascade do |t|
    t.integer "user_id"
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "judges", force: :cascade do |t|
    t.integer "user_id"
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lines", force: :cascade do |t|
    t.string "questioner"
    t.string "question"
    t.string "reader_answer"
    t.string "guesser_answer"
    t.boolean "judgement_correct"
    t.integer "whiteboard_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["whiteboard_id"], name: "index_lines_on_whiteboard_id"
  end

  create_table "readers", force: :cascade do |t|
    t.integer "user_id"
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_readers_on_game_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
  end

  create_table "whiteboards", force: :cascade do |t|
    t.integer "game_id"
    t.integer "document_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_whiteboards_on_document_id"
  end

end
