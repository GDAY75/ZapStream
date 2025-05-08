class CreateMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.text :summary
      t.string :length
      t.string :release_date
      t.string :genre
      t.string :director

      t.timestamps
    end
  end
end
