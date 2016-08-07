class CreateGenres < ActiveRecord::Migration[5.0]
  def change
    create_table :genres do |t|
      t.integer :moviedb_id, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
