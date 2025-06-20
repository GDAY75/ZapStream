require "open-uri"

class PagesController < ApplicationController

  PROVIDERS = ["Netflix", "Disney Plus", "Apple TV+", "Amazon Prime Video", "Canal+", "Max", "TF1+", "Paramount Plus", "Crunchyroll"]

  def home
  end

  def movie_details
    generate_movie_credits(@movie)
  end

  def pick_movie
    providers_filter = params[:providers] || []

    loop do
      generate_movie
      generate_movie_providers(@movie)
      @movie_providers ||= []

      if providers_filter.any?
        break if (providers_filter & @movie_providers).any?
      else
        break if (@movie_providers & PROVIDERS).any?
      end
    end

    generate_movie_details(@movie)

    render partial: "movie", locals: {
      movie: @movie,
      movie_title: @movie_title,
      movie_summary: @movie_summary,
      movie_release_date: @movie_release_date,
      movie_poster_url: @movie_poster_url,
      movie_length: @movie_length,
      movie_categories: @movie_categories,
      hours: @hours,
      min: @min,
      movie_providers: @movie_providers
    }
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
      movie_providers = response["results"]["FR"]["flatrate"]

      @movie_providers = movie_providers.map { |provider| provider["provider_name"] }
    end
  end

  def generate_movie_credits(movie)
    movie_id = params["movie"]["id"]
    url = "https://api.themoviedb.org/3/movie/#{movie_id}/credits?api_key=#{ENV['TMDB_KEY']}"
    response = JSON.parse(URI.open(url).read)

    if response["crew"].present?
      director = response["crew"].find { |person| person["job"] == "Director" }
      @movie_director = director ? director["name"] : "Inconnu"
      @movie_director_photo_url = "https://image.tmdb.org/t/p/w154#{director["profile_path"]}"
      @actors = response["cast"]
    end
  end
end
