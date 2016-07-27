class SourcesController < ApplicationController
  def index
    query = "SELECT DISTINCT display_name FROM sources"
    sources = Source.find_by_sql(query)
    render json: sources
  end
end
