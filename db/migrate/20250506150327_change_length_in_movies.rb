class ChangeLengthInMovies < ActiveRecord::Migration[7.1]
  def change
    change_column :movies, :length, :integer, using: 'length::integer'
  end
end
