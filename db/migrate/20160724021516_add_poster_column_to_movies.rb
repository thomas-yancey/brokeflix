class AddPosterColumnToMovies < ActiveRecord::Migration[5.0]
  def change
    add_column :movies, :poster, :string
  end
end
