class MovieDatabase
include HTTParty
  attr_accessor :omdb_id, :response, :key, :movie

  base_uri "https://api.themoviedb.org/3"
  def initialize(params={})
      @key = ENV["MOVIEDB_KEY"]
      @response = nil
      @omdb_id = params[:omdb_id] || ""
      @movie = params[:movie]
  end

  def call_general_info
    self.class.get("/movie/#{self.omdb_id}?api_key=#{self.key}")
  end

  def make_call_and_collect_imdb_and_genres
    self.call_general_info
    self.response = self.call_general_info
    if self.response["imdb_id"]
      movie.update_attributes(imdb_id: self.response["imdb_id"])
    end
    if self.response["genres"]
      self.collect_genres
    end
  end

  def collect_genres
    if self.response["genres"].length > 0
      self.response["genres"].each do |genre|
        curr_genre = Genre.find_by(moviedb_id: genre["id"])
        if curr_genre
          movie.genres << curr_genre
        else
          curr_genre = Genre.create(moviedb_id: genre["id"], name: genre["name"])
          movie.genres << curr_genre
        end
      end
    end
  end

  def call_movie_videos
    self.class.get("/movie/#{self.omdb_id}/videos?api_key=#{self.key}")
  end

  def set_trailer_response
    self.response = self.call_movie_videos
  end

  def grab_key_from_response
    return nil if !response["results"] || response["results"].length == 0
    response["results"].each do |data|
      if data["site"] == "YouTube" && data["name"].include?("Trailer") || data["type"] && data["type"].match(/Trailer/i)
        return data["key"]
      end
    end
    nil
  end

  def get_trailer_data
    self.set_trailer_response
    grab_key_from_response
  end

  def add_trailer_key_to_movie
    self.set_trailer_response
    self.movie.update_attributes(trailer: self.grab_key_from_response)
  end

  # Only used for initial pull of data
  def self.grab_key_for_all_movies_with_imdb_id
    movie_db_object = self.new
    movies = Movie.all
    movies.each_with_index do |movie, idx|
      next if !movie.trailer.nil?
      next if (movie.imdb_id.length == 0 && movie.omdb_id == 0)
      movie_db_object.imdb_id = movie.imdb_id.length == 0 ? movie.omdb_id : movie.imdb_id
      youtube_key = movie_db_object.get_trailer_data
      movie.update_attributes(trailer: youtube_key)
      sleep 0.2
    end
  end

end
# MovieDatabase.grab_key_for_all_movies_with_imdb_id
