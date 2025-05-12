require "open-uri"

class PagesController < ApplicationController

  def home
    generate_movie
  end

  private

  def generate_movie
    url = "https://api.themoviedb.org/3/discover/movie?api_key=#{ENV['TMDB_KEY']}&region=FR&language=fr-FR"
    response = JSON.parse(URI.open(url).read)

    if response["results"].present?
      movies = response["results"]
      @movie = movies.sample
      @movie_title = @movie['title']
      @movie_summary = @movie['overview']
    end
  end
end
