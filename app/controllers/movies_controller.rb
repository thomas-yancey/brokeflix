class MoviesController < ApplicationController

  def index
    query = "SELECT * FROM movies
             WHERE release_year > #{params[:start_year]}
             ORDER BY metascore
             DESC NULLS LAST"
    movies = Movie.paginate_by_sql(query, :page => params[:page], :per_page => 30)
    render json:  {
      current_page: movies.current_page,
      total_pages: movies.total_pages,
      total_entries: movies.total_entries,
      movies: movies.as_json(include: [:actors, :director, :sources] )
    }
  end

end
