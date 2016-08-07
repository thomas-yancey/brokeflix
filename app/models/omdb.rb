class Omdb
  include HTTParty
  attr_accessor :response,:imdb_id,:plot,:plot,:data_type, :movie

  base_uri "http://www.omdbapi.com/?"

  def initialize(params={})
      @response = nil
      @movie = params[:movie] || nil
      @imdb_id = params[:imdb_id] || nil
      @plot = params["plot"] || "full"
      @data_type = params["data_type"] || "json"
  end

  def make_request
    self.class.get("i=#{self.imdb_id}&plot=#{self.plot}&tomatoes=true&r=#{self.data_type}")
  end

  def store_response
    self.response = self.make_request.parsed_response
  end

  def collect_movie_data_from_response
    movie.imdb_rating = response["imdbRating"] if response["imdb_rating"]
    movie.runtime = response["Runtime"] if response["Runtime"]
    movie.language = response["Language"] if response["Language"]
    movie.metascore = response["Metascore"] if response["Metascore"]
    movie.imdb_votes = response["imdbVotes"] if response["imdbVotes"]
    movie.tomato_meter = response["tomatoMeter"] if response["tomatoMeter"]
    movie.tomato_reviews = response["tomatoReviews"] if response["tomatoReviews"]
    movie.tomato_consensus = response["tomatoConsensus"] if response["tomatoConsensus"]
    movie.tomato_url = response["tomatoURL"] if response["tomatoURL"]
    movie.save
  end

  def collect_actors_from_response
    if response["Actors"] && response["Actors"].length > 0
      actors = response["Actors"].split(",")
      actors.each do |actor|
        cast_member = Actor.find_or_create_by(name: actor)
        movie.actors << cast_member
      end
    end
  end

  def collect_director_from_response
    if response["Director"]
      director = Director.find_or_create_by(name: response["Director"])
      director.movies << movie
    end
  end

  def collect_all_data
    collect_movie_data_from_response
    collect_actors_from_response
    collect_director_from_response
  end

  def make_call_and_collect_all_data
    self.store_response
    self.collect_all_data
  end

  def get_data_for_all_movies_without_director
    movies = Movie.all
    movies.each do |movie|
      self.movie = movie
      self.imdb_id = movie.imdb_id
      self.store_response
      self.collect_all_data
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
