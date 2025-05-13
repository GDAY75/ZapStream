require "open-uri"

class PagesController < ApplicationController

  def home
    generate_movie
    generate_movie_details(@movie)
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
      @movie_release_date = @movie['release_date'].first(4)
    end

    return @movie
  end

  def generate_movie_details(movie)
    movie_id = movie["id"]
    url = "https://api.themoviedb.org/3/movie/#{movie_id}?api_key=#{ENV['TMDB_KEY']}&language=fr-FR"
    response = JSON.parse(URI.open(url).read)

    if response["runtime"].present?
      @movie_length = response["runtime"]

      if @movie_length >= 60
        @hours = @movie_length / 60
        @min = @movie_length - ( @hours * 60 )
      else
        @min = @movie_length
      end
    end
  end
end
