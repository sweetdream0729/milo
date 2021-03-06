# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170509163819) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", id: false, force: :cascade do |t|
    t.string   "plaid_acct_id"
    t.string   "account_name"
    t.string   "account_number"
    t.float    "available_balance"
    t.float    "current_balance"
    t.string   "institution_type"
    t.string   "name"
    t.string   "numbers"
    t.string   "acct_subtype"
    t.string   "acct_type"
    t.integer  "user_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "public_token_id"
    t.integer  "checking_id"
    t.string   "bank_account_number"
    t.string   "bank_routing_number"
    t.integer  "failed_verification_attempt"
  end

  create_table "businesses", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "frequency"
    t.integer  "owner"
    t.integer  "current_contribution"
    t.integer  "total_contribution"
    t.integer  "max_contribution"
    t.integer  "match_percent"
  end

  create_table "checkings", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "plaid_acct_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "debts", force: :cascade do |t|
    t.string   "account_name"
    t.string   "account_number"
    t.string   "debt_type"
    t.decimal  "begin_balance"
    t.decimal  "current_balance"
    t.decimal  "minimum_payment"
    t.decimal  "credit_limit"
    t.decimal  "apr"
    t.date     "due_date"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "goals", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "amount"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
    t.boolean  "completed"
    t.string   "gtype"
    t.decimal  "percentage"
    t.decimal  "balance"
    t.boolean  "preset"
  end

  add_index "goals", ["user_id", "created_at"], name: "index_goals_on_user_id_and_created_at", using: :btree
  add_index "goals", ["user_id"], name: "index_goals_on_user_id", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",                               null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",                          null: false
    t.string   "scopes"
    t.string   "previous_refresh_token", default: "", null: false
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "public_tokens", force: :cascade do |t|
    t.string "token"
    t.string "user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "token_data", force: :cascade do |t|
    t.integer  "expires_in"
    t.string   "scope"
    t.string   "account_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "access_token"
    t.string   "refresh_token"
  end

  create_table "transactions", id: false, force: :cascade do |t|
    t.string   "plaid_trans_id"
    t.string   "account_id"
    t.float    "amount"
    t.string   "trans_name"
    t.integer  "plaid_cat_id"
    t.string   "plaid_cat_type"
    t.date     "date"
    t.string   "vendor_address"
    t.string   "vendor_city"
    t.string   "vendor_state"
    t.string   "vendor_zip"
    t.float    "vendor_lat"
    t.float    "vendor_lon"
    t.boolean  "pending"
    t.string   "pending_transaction"
    t.integer  "name_score"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.float    "new_amount"
    t.float    "roundup"
    t.integer  "user_id"
  end

  create_table "transfers", force: :cascade do |t|
    t.string   "dwolla_url"
    t.string   "user_id"
    t.string   "roundup_count"
    t.string   "status"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "transfer_type"
    t.string   "roundup_amount"
    t.string   "date"
    t.boolean  "tech_fee_charged"
    t.integer  "business_id"
  end

  add_index "transfers", ["business_id"], name: "index_transfers_on_business_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                                          default: "",    null: false
    t.string   "encrypted_password",                             default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                  default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.boolean  "invited",                                        default: false
    t.boolean  "admin",                                          default: false
    t.string   "referral_code"
    t.string   "name"
    t.string   "zip"
    t.string   "mobile_number"
    t.string   "verification_code"
    t.boolean  "is_verified"
    t.string   "dwolla_id"
    t.string   "dwolla_funding_source"
    t.boolean  "on_demand"
    t.boolean  "agreement"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "plaid_access_token"
    t.integer  "failed_attempts",                                default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "account_balance",                                default: 0
    t.integer  "business_id"
    t.boolean  "long_tail"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",                              default: 0
    t.boolean  "bank_not_verified"
    t.boolean  "pause_savings"
    t.integer  "employer_contribution"
    t.integer  "pending_contribution"
    t.string   "first_name"
    t.string   "last_name"
    t.decimal  "budget",                 precision: 8, scale: 2
    t.string   "auth_token",                                     default: ""
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", unique: true, using: :btree
  add_index "users", ["business_id"], name: "index_users_on_business_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "webhook_events", force: :cascade do |t|
    t.string   "service"
    t.string   "response_id"
    t.string   "topic"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_foreign_key "goals", "users"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "transfers", "businesses"
end
