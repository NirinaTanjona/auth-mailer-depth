ActiveRecord::Schema[7.0].define(version: 2022_05_31_170425) do
  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmed_at"
    t.string "password_digest"
  end

end
