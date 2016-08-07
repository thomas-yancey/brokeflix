task :create_new_movies => :environment do

  guidebox = Guidebox.new({curr_movie: 250})
  guidebox.create_and_store_new_movies
  new_movies = guidebox.new_movies_array
  # grab movie db info and omdb info
  new_movies.each do |movie_id|
    movie = Movie.find(movie_id)
    imdb_id = movie.omdb_id || movie.imdb_id
    movie_db = MovieDatabase.new({movie: movie,
                                  imdb_id: imdb_id})
    movie_db.add_trailer_key_to_movie
    movie_db.make_call_and_collect_imdb_and_genres
    if movie.imdb_id && movie.imdb_id.length > 0
      omdb = Omdb.new({movie: movie, imdb_id: movie.imdb_id})
      omdb.make_call_and_collect_all_data
    end
  end

end

task :update_changed_movies => :environment do
  guidebox = Guidebox.new
  guidebox.change_update_movie_sources
end
