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

ActiveRecord::Schema.define(version: 20171009123703) do

  create_table "collections", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "collections_documents", id: false, force: :cascade do |t|
    t.integer "collection_id", null: false
    t.integer "document_id", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.string "kind"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title", default: "untitled", null: false
  end

  create_table "documents_requests", id: false, force: :cascade do |t|
    t.integer "request_id", null: false
    t.integer "document_id", null: false
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

  create_table "invites", force: :cascade do |t|
    t.integer "sync_games_manager_id"
    t.integer "document_id"
    t.integer "reader_id"
    t.integer "guesser_id"
    t.integer "judge_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_invites_on_document_id"
    t.index ["sync_games_manager_id"], name: "index_invites_on_sync_games_manager_id"
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

  create_table "managers", force: :cascade do |t|
    t.integer "offline"
    t.text "idle"
    t.integer "queued"
    t.integer "playing"
    t.integer "active_synchronous_games"
    t.integer "concluded_synchronous_games"
    t.integer "active_asynchronous_games"
    t.integer "concluded_asynchronous_games"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "multiplayer_queues", force: :cascade do |t|
    t.integer "player1"
    t.integer "player2"
    t.integer "player3"
    t.boolean "created"
    t.integer "players_processed"
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "queued_players", force: :cascade do |t|
    t.integer "user_id"
    t.integer "multiplayer_queue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["multiplayer_queue_id"], name: "index_queued_players_on_multiplayer_queue_id"
  end

  create_table "readers", force: :cascade do |t|
    t.integer "user_id"
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_readers_on_game_id"
  end

  create_table "requests", force: :cascade do |t|
    t.boolean "reader"
    t.boolean "guesser"
    t.boolean "judge"
    t.integer "sync_games_manager_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sync_games_manager_id"], name: "index_requests_on_sync_games_manager_id"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "sync_games_managers", force: :cascade do |t|
    t.text "user_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.text "known_documents"
    t.integer "invite_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.index ["invite_id"], name: "index_users_on_invite_id"
  end

  create_table "waiting_players", force: :cascade do |t|
    t.integer "user_id"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "whiteboards", force: :cascade do |t|
    t.integer "game_id"
    t.integer "document_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_whiteboards_on_document_id"
  end

end
