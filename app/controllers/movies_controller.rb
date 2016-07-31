class MoviesController < ApplicationController

  def index

    search_text = params[:title_search].downcase
    movies = Movie.where("release_year >= ? AND release_Year <= ?",
    params[:start_year],params[:end_year]).includes(
      :sources).where(
      sources: {display_name: params[:selectedSources]}).where(
      "Lower(title) LIKE ?", '%' + search_text + '%'
      ).order(
      "#{params[:review_field]} DESC NULLS LAST"
      )
    movies = movies.paginate(:page => params[:page], :per_page => 32)
    render json:  {
      current_page: movies.current_page,
      total_pages: movies.total_pages,
      total_entries: movies.total_entries,
      movies: movies.as_json(include: [:actors, :director, :sources] )
    }
  end

end
