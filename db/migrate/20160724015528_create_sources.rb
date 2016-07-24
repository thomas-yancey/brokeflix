class CreateSources < ActiveRecord::Migration[5.0]
  def change
    create_table :sources do |t|
      t.references :movie, null: false
      t.string :name
      t.string :display_name
      t.string :link

      t.timestamps
    end
  end
end
