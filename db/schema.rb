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

ActiveRecord::Schema.define(version: 20160807030559) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actors", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "actors_movies", id: false, force: :cascade do |t|
    t.integer "actor_id", null: false
    t.integer "movie_id", null: false
    t.index ["actor_id", "movie_id"], name: "index_actors_movies_on_actor_id_and_movie_id", using: :btree
    t.index ["movie_id", "actor_id"], name: "index_actors_movies_on_movie_id_and_actor_id", using: :btree
  end

  create_table "directors", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genres", force: :cascade do |t|
    t.integer  "moviedb_id", null: false
    t.integer  "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genres_movies", id: false, force: :cascade do |t|
    t.integer "genre_id", null: false
    t.integer "movie_id", null: false
    t.index ["genre_id", "movie_id"], name: "index_genres_movies_on_genre_id_and_movie_id", using: :btree
    t.index ["movie_id", "genre_id"], name: "index_genres_movies_on_movie_id_and_genre_id", using: :btree
  end

  create_table "movies", force: :cascade do |t|
    t.integer  "guidebox_id"
    t.integer  "omdb_id"
    t.string   "title"
    t.string   "rating"
    t.string   "imdb_id"
    t.integer  "release_year"
    t.integer  "wiki_id"
    t.string   "trailer"
    t.text     "overview"
    t.string   "metacritic_url"
    t.integer  "runtime"
    t.string   "language"
    t.integer  "metascore"
    t.integer  "imdb_rating"
    t.integer  "imdb_votes"
    t.integer  "tomato_meter"
    t.integer  "tomato_reviews"
    t.string   "tomato_consensus"
    t.string   "tomato_url"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "poster"
    t.integer  "director_id"
  end

  create_table "sources", force: :cascade do |t|
    t.integer  "movie_id",     null: false
    t.string   "name"
    t.string   "display_name"
    t.string   "link"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["movie_id"], name: "index_sources_on_movie_id", using: :btree
  end

end
