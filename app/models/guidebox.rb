class Guidebox
  include HTTParty
  attr_accessor :curr_movie, :movie_count, :sources, :platform, :response, :total_results

  base_uri "http://api-public.guidebox.com/v1.43/US/#{ENV["GUIDEBOX_KEY"]}"
  def initialize(params={})
      @curr_movie = params[:curr_movie] || 1
      @movie_count = params[:movie_count] || 250
      @sources = params[:sources] || "free"
      @platform = params[:platform] || "web"
      @response = nil
      @total_results = 0
  end

  def request_movies
    self.class.get("/movies/all/#{self.curr_movie}/#{self.movie_count}/#{self.sources}/#{self.platform}")
  end

  def store_response
    self.response = self.request_movies
  end

  def set_count
    self.total_results = self.response["total_results"]
  end

  def collect_all_movies
    self.store_response
    self.set_count

    until self.curr_movie > self.total_results
      self.iterate_through_curr_response
      self.curr_movie += self.movie_count
      self.store_response
      puts curr_movie
    end
  end

  def iterate_through_curr_response
    self.response["results"].each do |movie|
      new_movie = Movie.find_or_create_by(guidebox_id: movie["id"])
      new_movie.title = movie["title"] if movie["title"]
      new_movie.release_year = movie["release_year"] if movie["release_year"]
      new_movie.omdb_id = movie["themoviedb"] if movie["themoviedb"]
      new_movie.imdb_id = movie["imdb"] if movie["imdb"]
      new_movie.rating = movie["rating"] if movie["rating"]
      new_movie.wiki_id = movie["wikipedia_id"] if movie["wikipedia_id"]
      new_movie.save
    end
  end

  # t.integer :ombd_id
  # t.string :title
  # t.string :rating
  # t.string :imdb_id
  # t.integer :release_year
  # t.integer :wiki_id
  # t.string :trailer
  # t.text :overview
  # t.string :metacritic_url
  # t.integer :runtime
  # t.string :language
  # t.integer :metascore
  # t.integer :imdb_rating
  # t.integer :imdb_votes
  # t.integer :tomato_meter
  # t.integer :tomato_reviews
  # t.string :tomato_consensus
  # t.string :tomato_url

end
