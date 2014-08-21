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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110408131715) do

  create_table "answer_marks", :force => true do |t|
    t.integer  "question_id"
    t.integer  "answer_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answer_marks", ["answer_id", "question_id"], :name => "index_answer_marks_on_answer_id_and_question_id", :unique => true
  add_index "answer_marks", ["answer_id"], :name => "index_answer_marks_on_answer_id"
  add_index "answer_marks", ["question_id"], :name => "index_answer_marks_on_question_id"
  add_index "answer_marks", ["user_id", "question_id"], :name => "index_answer_marks_on_user_id_and_question_id", :unique => true
  add_index "answer_marks", ["user_id"], :name => "index_answer_marks_on_user_id"

  create_table "comments", :force => true do |t|
    t.string   "content"
    t.integer  "commenter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "insult_id"
  end

  create_table "daily_answers", :force => true do |t|
    t.string   "content"
    t.integer  "daily_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "answer_mark_id"
  end

  add_index "daily_answers", ["answer_mark_id"], :name => "index_daily_answers_on_answer_mark_id"

  create_table "daily_questions", :force => true do |t|
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "insults", :force => true do |t|
    t.string   "content"
    t.integer  "insulter_id"
    t.integer  "insulted_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "insults", ["insulted_id"], :name => "index_insults_on_insulted_id"
  add_index "insults", ["insulter_id"], :name => "index_insults_on_insulter_id"

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], :name => "index_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "users", :force => true do |t|
    t.string   "username",           :limit => 30
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin",                             :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.string   "blurb",              :limit => 600
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "votes", :force => true do |t|
    t.boolean  "vote",          :default => false
    t.integer  "voteable_id",                      :null => false
    t.string   "voteable_type",                    :null => false
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["voteable_id", "voteable_type"], :name => "index_votes_on_voteable_id_and_voteable_type"
  add_index "votes", ["voter_id", "voter_type", "voteable_id", "voteable_type"], :name => "fk_one_vote_per_user_per_entity", :unique => true
  add_index "votes", ["voter_id", "voter_type"], :name => "index_votes_on_voter_id_and_voter_type"

end
