class Guidebox
  include HTTParty
  attr_accessor :curr_movie, :movie_count, :sources, :platform,
    :response, :total_results, :page, :total_pages, :change_results,
    :movies_with_updates, :change_curr_page, :change_total_page

  base_uri "http://api-public.guidebox.com/v1.43/US/#{ENV["GUIDEBOX_KEY"]}"
  def initialize(params={})
      @curr_movie = params[:curr_movie] || 1
      @movie_count = params[:movie_count] || 250
      @sources = params[:sources] || "free"
      @platform = params[:platform] || "web"
      @response = nil
      @total_results = 0
      @total_pages = nil
      @page = params[:page] || 1
      @change_results = nil
      @movies_with_updates = []
      @change_curr_page = 1
      @change_total_page = nil
  end

  def change_update_movie_sources
    self.change_collect_all_ids_in_database
    self.movies_with_updates.each do |movie_id|
      self.change_update_individual_movie_sources(movie_id)
    end
  end

  def change_update_individual_movie_sources(movie_id)
    self.response = self.collect_individual_movie_data_id(movie_id)
    curr_movie = Movie.find_by(guidebox_id: movie_id)
    if self.response["free_web_sources"]
      curr_movie.sources.destroy_all
      self.add_movie_sources(curr_movie)
    end
  end

  def change_collect_all_ids_in_database
    self.change_store_response
    until self.change_curr_page == self.change_total_page
      self.change_collect_curr_page_change_ids
      self.change_curr_page = self.change_curr_page + 1
      self.change_store_response
    end
  end

  def change_collect_curr_page_change_ids
    self.change_results.each do |movie|
      if Movie.find_by(guidebox_id: movie["id"])
        movies_with_updates << movie["id"]
      end
    end
  end

  def change_store_response
    total_response = self.change_request
    self.change_curr_page = total_response["page"]
    self.change_total_page = total_response["total_pages"]
    self.change_results = total_response["results"]
  end

  def change_request
    update_time = DateTime.now - 7.days
    unix_update_time = update_time.to_i
    self.class.get("/updates/movies/changes/#{unix_update_time}/?limit=1000&page=#{self.change_curr_page}")
  end

  def request_movies
    self.class.get("/movies/all/#{self.curr_movie}/#{self.movie_count}/#{self.sources}/#{self.platform}")
  end

  def store_all_movies_response
    self.response = self.request_movies
  end

  def set_count
    self.total_results = self.response["total_results"]
  end

  def collect_all_movies
    self.store_all_movies_response
    self.set_count

    until self.curr_movie > self.total_results
      self.iterate_through_and_create_all_movies
      self.curr_movie += self.movie_count
      self.store_all_movies_response
    end
  end

  def iterate_through_and_create_all_movies
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

  def collect_individual_movie_data(movie)
    self.class.get("/movie/#{movie.guidebox_id}")
  end

  def collect_individual_movie_data_id(id)
    self.class.get("/movie/#{id}")
  end

  def store_individual_response(movie)
    self.response = self.collect_individual_movie_data(movie)
  end

  def update_individual_movie(movie)
    self.store_individual_response(movie)
    movie.overview = response["overview"] if response["overview"]
    movie.overview = response["overview"] if response["overview"]
    movie.poster = response["poster_240x342"] if response["poster_240x342"]
    if response["trailers"] && response["trailers"]["web"].any?
      movie.trailer = response["trailers"]["web"][0]["embed"]
    end
    movie.metacritic_url = response["metacritic"] if response["metacritic"]
    movie.save
  end

  def add_movie_sources(movie)
    response["free_web_sources"].each do |web_source|
      source = Source.new(movie_id: movie.id)
      source.name = web_source["source"]
      source.display_name = web_source["display_name"]
      source.link = web_source["link"]
      source.save
    end
  end

  def add_info_to_all_movies
    movies = Movie.where(overview: nil)
    movies.each do |curr_movie|
      self.update_individual_movie(curr_movie)
      self.add_movie_sources(curr_movie)
    end
  end

end
