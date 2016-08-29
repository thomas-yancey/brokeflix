class MoviesController < ApplicationController

  def index
    search_text = params[:title_search].downcase
    # make actually search directors and actors

    movies = Movie.where("release_year >= ? AND release_Year <= ?",
    params[:start_year],params[:end_year]).includes(
      :sources, :director, :actors, :genres).where(
      sources: {display_name: params[:selectedSources]}
      # genres: {ids: [params[:genres]]}
      ).where(
      Select * FROM movies where actorsLOWER(actors.name)
      "LOWER(title) LIKE ?
      OR LOWER(actors.name) LIKE ?
      OR LOWER(directors.name) LIKE ?",
      '%' + search_text + '%',
      '%' + search_text + '%',
      '%' + search_text + '%'
      ).order(
      "#{params[:review_field]} DESC NULLS LAST, movies.id DESC"
      )
    movies = movies.paginate(:page => params[:page], :per_page => 32)
    render json:  {
      current_page: movies.current_page,
      total_pages: movies.total_pages,
      total_entries: movies.total_entries,
      movies: movies.as_json(include: [:actors, :director, :sources, :genres] )
    }
  end

end
