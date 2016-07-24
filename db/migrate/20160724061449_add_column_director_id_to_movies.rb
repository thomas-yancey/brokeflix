class AddColumnDirectorIdToMovies < ActiveRecord::Migration[5.0]
  def change
    add_column :movies, :director_id, :integer, index: true
  end
end
