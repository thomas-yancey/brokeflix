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

  def call_movie_images
    self.class.get("/movie/#{self.movie.omdb_id}/images?api_key=#{self.key}")
  end

  def make_call_and_collect_imdb_and_genres
    self.response = self.call_general_info
    sleep 0.2
    if self.response["imdb_id"]
      movie.update_attributes(imdb_id: self.response["imdb_id"])
    end
    self.collect_genres if self.response["genres"]
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
    self.response = self.call_movie_videos
    sleep 0.1
    self.movie.update_attributes(trailer: self.grab_key_from_response)
  end

  def add_image_and_poster
    self.response = self.call_movie_images
    backdrop, mobile_poster = "", ""

    if response["posters"] && response["posters"].any?
      mobile_poster = "https://image.tmdb.org/t/p/w300_and_h450_bestv2#{self.highest_rated_image("posters")}"
    end

    if response["backdrops"] && response["backdrops"].any?
      backdrop = "https://image.tmdb.org/t/p/w500_and_h281_bestv2#{self.highest_rated_image("backdrops")}"
    end

    puts backdrop
    puts mobile_poster

  end

  def highest_rated_image(type)

    vote_count = 0
    image_file_path = ""
    response[type].each do |image|
      if image["vote_count"] > vote_count
        image_file_path = image["file_path"]
        vote_count = image["vote_count"]
      end
    end

    image_file_path

  end


end
# MovieDatabase.grab_key_for_all_movies_with_imdb_id
