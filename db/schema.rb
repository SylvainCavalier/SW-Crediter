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

ActiveRecord::Schema[7.1].define(version: 2026_05_06_173040) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "force_visions", force: :cascade do |t|
    t.string "name", null: false
    t.string "qr_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["qr_token"], name: "index_force_visions_on_qr_token", unique: true
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "holonew_reads", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "holonew_id", null: false
    t.boolean "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["holonew_id"], name: "index_holonew_reads_on_holonew_id"
    t.index ["user_id"], name: "index_holonew_reads_on_user_id"
  end

  create_table "holonews", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "target_user"
    t.string "target_group"
    t.boolean "read", default: false
    t.string "sender_alias"
    t.bigint "target_npc_character_id"
    t.bigint "sender_npc_character_id"
    t.boolean "draft", default: false, null: false
    t.index ["draft"], name: "index_holonews_on_draft"
    t.index ["sender_npc_character_id"], name: "index_holonews_on_sender_npc_character_id"
    t.index ["target_npc_character_id"], name: "index_holonews_on_target_npc_character_id"
    t.index ["user_id"], name: "index_holonews_on_user_id"
  end

  create_table "inventory_objects", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.text "description"
    t.integer "price"
    t.string "rarity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "npc_character_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "npc_character_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["npc_character_id"], name: "index_npc_character_users_on_npc_character_id"
    t.index ["user_id", "npc_character_id"], name: "index_npc_char_users_on_user_and_npc", unique: true
    t.index ["user_id"], name: "index_npc_character_users_on_user_id"
  end

  create_table "npc_characters", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_npc_characters_on_lower_name", unique: true
  end

  create_table "pazaak_games", force: :cascade do |t|
    t.bigint "host_id", null: false
    t.bigint "guest_id"
    t.integer "status", default: 0, null: false
    t.integer "current_turn_user_id"
    t.integer "round_number", default: 1, null: false
    t.integer "wins_host", default: 0, null: false
    t.integer "wins_guest", default: 0, null: false
    t.text "host_state", default: "{}", null: false
    t.text "guest_state", default: "{}", null: false
    t.integer "last_drawn_card"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "first_player_id"
    t.index ["first_player_id"], name: "index_pazaak_games_on_first_player_id"
    t.index ["guest_id"], name: "index_pazaak_games_on_guest_id"
    t.index ["host_id"], name: "index_pazaak_games_on_host_id"
  end

  create_table "pazaak_invitations", force: :cascade do |t|
    t.bigint "inviter_id", null: false
    t.bigint "invitee_id", null: false
    t.bigint "pazaak_game_id"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "stake", default: 0, null: false
    t.index ["invitee_id"], name: "index_pazaak_invitations_on_invitee_id"
    t.index ["inviter_id", "invitee_id", "status"], name: "idx_on_inviter_id_invitee_id_status_362b576a3f"
    t.index ["inviter_id"], name: "index_pazaak_invitations_on_inviter_id"
    t.index ["pazaak_game_id"], name: "index_pazaak_invitations_on_pazaak_game_id"
  end

  create_table "pazaak_presences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "last_seen_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_pazaak_presences_on_user_id", unique: true
  end

  create_table "pazaak_stats", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "games_played", default: 0, null: false
    t.integer "games_won", default: 0, null: false
    t.integer "games_lost", default: 0, null: false
    t.integer "rounds_won", default: 0, null: false
    t.integer "rounds_lost", default: 0, null: false
    t.integer "rounds_tied", default: 0, null: false
    t.integer "games_abandoned", default: 0, null: false
    t.integer "best_win_streak", default: 0, null: false
    t.integer "worst_lose_streak", default: 0, null: false
    t.integer "current_win_streak", default: 0, null: false
    t.integer "current_lose_streak", default: 0, null: false
    t.integer "credits_won", default: 0, null: false
    t.integer "credits_lost", default: 0, null: false
    t.integer "stake_max", default: 0, null: false
    t.integer "stake_min", default: 0, null: false
    t.integer "stake_sum", default: 0, null: false
    t.integer "stake_count", default: 0, null: false
    t.integer "playmate_user_id"
    t.integer "nemesis_user_id"
    t.integer "victim_user_id"
    t.jsonb "opponent_counters", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_pazaak_stats_on_user_id", unique: true
  end

  create_table "repairs", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.jsonb "required_parts", default: [], null: false
    t.string "code", null: false
    t.string "qr_token", null: false
    t.jsonb "repaired_by", default: [], null: false
    t.integer "reward_credits", default: 40, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["qr_token"], name: "index_repairs_on_qr_token", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "endpoint"
    t.text "p256dh"
    t.text "auth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "receiver_id"
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_contacts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "contactable_type", null: false
    t.bigint "contactable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contactable_type", "contactable_id"], name: "index_user_contacts_on_contactable"
    t.index ["user_id", "contactable_type", "contactable_id"], name: "index_user_contacts_uniqueness", unique: true
    t.index ["user_id"], name: "index_user_contacts_on_user_id"
  end

  create_table "user_inventory_objects", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "inventory_object_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_object_id"], name: "index_user_inventory_objects_on_inventory_object_id"
    t.index ["user_id", "inventory_object_id"], name: "idx_on_user_id_inventory_object_id_b86c0a23ac", unique: true
    t.index ["user_id"], name: "index_user_inventory_objects_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "credits", default: 0
    t.string "username"
    t.bigint "group_id", null: false
    t.jsonb "pazaak_deck", default: []
    t.datetime "last_subsidy_at"
    t.string "character_class"
    t.string "real_first_name"
    t.boolean "character_name_chosen", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["group_id"], name: "index_users_on_group_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "holonew_reads", "holonews"
  add_foreign_key "holonew_reads", "users"
  add_foreign_key "holonews", "npc_characters", column: "sender_npc_character_id"
  add_foreign_key "holonews", "npc_characters", column: "target_npc_character_id"
  add_foreign_key "holonews", "users"
  add_foreign_key "npc_character_users", "npc_characters"
  add_foreign_key "npc_character_users", "users"
  add_foreign_key "pazaak_games", "users", column: "guest_id"
  add_foreign_key "pazaak_games", "users", column: "host_id"
  add_foreign_key "pazaak_invitations", "pazaak_games"
  add_foreign_key "pazaak_invitations", "users", column: "invitee_id"
  add_foreign_key "pazaak_invitations", "users", column: "inviter_id"
  add_foreign_key "pazaak_presences", "users"
  add_foreign_key "pazaak_stats", "users"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "user_contacts", "users"
  add_foreign_key "user_inventory_objects", "inventory_objects"
  add_foreign_key "user_inventory_objects", "users"
  add_foreign_key "users", "groups"
end
