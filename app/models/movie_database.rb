class MovieDatabase
include HTTParty
  attr_accessor :response, :key, :movie

  base_uri "https://api.themoviedb.org/3"
  def initialize(params={})
      @key = ENV["MOVIEDB_KEY"]
      @movie = params[:movie]
      @response = nil
  end

  def call_general_info
    self.class.get("/movie/#{self.movie.omdb_id}?api_key=#{self.key}")
  end

  def call_movie_videos
    self.class.get("/movie/#{self.movie.omdb_id}/videos?api_key=#{self.key}")
  end

  def make_call_and_collect_imdb_and_genres
    self.response = self.call_general_info
    if self.response["imdb_id"]
      movie.update_attributes(imdb_id: self.response["imdb_id"])
    end
    if self.response["genres"]
      self.collect_genres
    end
  end

  def collect_genres
    if !!self.response["genres"] && self.response["genres"].length > 0
      self.response["genres"].each do |genre|
        curr_genre = Genre.find_by(moviedb_id: genre["id"])
        if !self.movie.genres.find_by(moviedb_id: genre["id"])
          if curr_genre
            self.movie.genres << curr_genre
          else
            curr_genre = Genre.create(moviedb_id: genre["id"], name: genre["name"])
            self.movie.genres << curr_genre
          end
        end
      end
    end
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

  def add_trailer_key_to_movie
    self.set_trailer_response
    sleep 0.1
    self.movie.update_attributes(trailer: self.grab_key_from_response)
  end

end
# MovieDatabase.grab_key_for_all_movies_with_imdb_id
