require "open-uri"

class PagesController < ApplicationController

  def home
    until @movie_provider == "Netflix" || @movie_provider == "Disney Plus" || @movie_provider == "Apple TV+" || @movie_provider == "Amazon Prime Video"
      generate_movie
      generate_movie_providers(@movie)
    end
    generate_movie_details(@movie)
    generate_movie_credits(@movie)
  end

  private

  def generate_movie
    url = "https://api.themoviedb.org/3/movie/top_rated?api_key=#{ENV['TMDB_KEY']}&region=FR&language=fr-FR&page=#{rand(1..500)}"
    response = JSON.parse(URI.open(url).read)

    if response["results"].present?
      movies = response["results"]
      @movie = movies.sample
      @movie_title = @movie['title']
      @movie_summary = @movie['overview']
      @movie_release_date = @movie['release_date'].first(4)
      @movie_poster_url = "https://image.tmdb.org/t/p/w300#{@movie['poster_path']}"
    end

    return @movie
  end

  def generate_movie_details(movie)
    movie_id = movie["id"]
    url = "https://api.themoviedb.org/3/movie/#{movie_id}?api_key=#{ENV['TMDB_KEY']}&language=fr-FR"
    response = JSON.parse(URI.open(url).read)

    if response["runtime"].present?
      @movie_length = response["runtime"]
      @movie_categories = response["genres"]

      if @movie_length >= 60
        @hours = @movie_length / 60
        @min = @movie_length - ( @hours * 60 )
      else
        @min = @movie_length
      end
    end
  end

  def generate_movie_providers(movie)
    movie_id = movie["id"]
    url = "https://api.themoviedb.org/3/movie/#{movie_id}/watch/providers?api_key=#{ENV['TMDB_KEY']}"
    response = JSON.parse(URI.open(url).read)

    if response["results"].present? && response["results"]["FR"].present? && response["results"]["FR"]["flatrate"].present?
      @movie_provider = response["results"]["FR"]["flatrate"][0]["provider_name"]
    end
  end

  def generate_movie_credits(movie)
    movie_id = movie["id"]
    url = "https://api.themoviedb.org/3/movie/#{movie_id}/credits?api_key=#{ENV['TMDB_KEY']}"
    response = JSON.parse(URI.open(url).read)

    if response["crew"].present?
      director = response["crew"].find { |person| person["job"] == "Director" }
      @movie_director = director ? director["name"] : "Inconnu"
    end
  end
end
