class MovieDatabase
include HTTParty
  attr_accessor :imdb_id, :response, :key

  base_uri "https://api.themoviedb.org/3"
  def initialize(params={})
      @key = ENV["MOVIEDB_KEY"]
      @response = nil
      @imdb_id = params[:imdb_id] || ""
  end

  def call_movie_videos
    self.class.get("/movie/#{self.imdb_id}/videos?api_key=#{self.key}")
  end

  def set_response
    self.response = self.call_movie_videos
  end

  def get_trailer_data
    self.set_response
    grab_key_from_response
  end

  def grab_key_from_response
    return nil if !response["results"] || response["results"].length == 0
    response["results"].each do |data|
      puts data
      return data["key"] if data["site"] == "YouTube" && data["name"].include?("Trailer") || data["type"] && data["type"].match(/Trailer/i)
    end
    nil
  end

  def self.grab_key_for_all_movies_with_imdb_id
    movie_db_object = self.new({imdb_id: nil})
    movies = Movie.all
    movies.each_with_index do |movie, idx|
      puts idx
      puts !movie.trailer.nil?
      next if !movie.trailer.nil?
      next if (movie.imdb_id.length == 0 && movie.omdb_id == 0)
      puts "#{movie.trailer.nil?} -- here"
      movie_db_object.imdb_id = movie.imdb_id.length == 0 ? movie.omdb_id : movie.imdb_id
      puts movie_db_object.imdb_id
      youtube_key = movie_db_object.get_trailer_data
      movie.update_attributes(trailer: youtube_key)
      sleep 0.2
    end
  end

end
# MovieDatabase.grab_key_for_all_movies_with_imdb_id