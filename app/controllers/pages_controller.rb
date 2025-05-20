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
    details_url = "https://api.themoviedb.org/3/movie/#{movie_id}?api_key=#{ENV['TMDB_KEY']}&language=fr-FR"
    credits_url = "https://api.themoviedb.org/3/movie/#{movie_id}/credits?api_key=#{ENV['TMDB_KEY']}"

    details = JSON.parse(URI.open(details_url).read)
    credits = JSON.parse(URI.open(credits_url).read)

    if details["runtime"].present?
      @movie_length = details["runtime"]
      director = credits["crew"].find { |person| person["job"] == "Director" }
      @movie_director = director ? director["name"] : "Inconnu"
      @movie_categories = details["genres"]

      if @movie_length >= 60
        @hours = @movie_length / 60
        @min = @movie_length - ( @hours * 60 )
      else
        @min = @movie_length
      end
    end
  end
end
