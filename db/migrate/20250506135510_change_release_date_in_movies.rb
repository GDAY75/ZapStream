class ChangeReleaseDateInMovies < ActiveRecord::Migration[7.1]
  def change
    change_column :movies, :release_date, :date, using: 'release_date::date'
  end
end
