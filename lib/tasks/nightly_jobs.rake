task :create_new_movies => :environment do
  guidebox = Guidebox.new
  guidebox.create_and_store_new_movies
  new_movies = guidebox.new_movies_array
  # grab movie db info and omdb info
  new_movies.each do |movie_id|
    movie = Movie.find(movie_id)

    if !movie.omdb_id.nil? && movie.omdb_id > 0

      movie_db = MovieDatabase.new({movie: movie})
      movie_db.add_trailer_key_to_movie
      movie_db.make_call_and_collect_imdb_and_genres

      if movie.imdb_id && movie.imdb_id.length > 0
        omdb = Omdb.new({movie: movie, imdb_id: movie.imdb_id})
        omdb.make_call_and_collect_all_data
      end

    end
  end
end

task :update_sources_of_changed_movies => :environment do
  guidebox = Guidebox.new
  guidebox.change_update_movie_sources
end

task :add_genres_to_all_movies_once => :environment do
  Movie.where.not(omdb_id: 0).each do |movie|
    if movie.genres.empty?
      sleep 0.25
      movie_db = MovieDatabase.new({movie: movie})
      movie_db.response = movie_db.call_general_info
      sleep 0.1
      movie_db.collect_genres
    end
  end
end
