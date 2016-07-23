class CreateMovies < ActiveRecord::Migration[5.0]
  def change
    create_table :movies do |t|
      t.integer :guidebox_id
      t.integer :omdb_id
      t.string :title
      t.string :rating
      t.string :imdb_id
      t.integer :release_year
      t.integer :wiki_id
      t.string :trailer
      t.text :overview
      t.string :metacritic_url
      t.integer :runtime
      t.string :language
      t.integer :metascore
      t.integer :imdb_rating
      t.integer :imdb_votes
      t.integer :tomato_meter
      t.integer :tomato_reviews
      t.string :tomato_consensus
      t.string :tomato_url

      t.timestamps
    end
  end
end
