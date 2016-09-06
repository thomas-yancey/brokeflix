class AddMobilePosterToMovies < ActiveRecord::Migration[5.0]
  def change
    add_column :movies, :mobile_poster, :string
    add_column :movies, :backdrop, :string
  end
end
