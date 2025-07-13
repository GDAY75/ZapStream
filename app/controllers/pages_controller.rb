require "open-uri"

class PagesController < ApplicationController

  PROVIDERS = ["Netflix", "Disney Plus", "Apple TV+", "Amazon Prime Video", "Canal+", "Max", "TF1+", "Paramount Plus", "Crunchyroll"]

  def home
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
      movie_language: @movie_language,
      movie_poster_url: @movie_poster_url,
      movie_length: @movie_length,
      movie_categories: @movie_categories,
      hours: @hours,
      min: @min,
      movie_providers: @movie_providers
    }
  end

  def pick_serie
    providers_filter = params[:providers] || []
    selected_media = params[:media] || [] # Expecting array like ["series"] or ["movies", "series"]

    attempts = 0
    max_attempts = 10

    begin
      loop do
        generate_serie
        generate_serie_providers(@serie)

        @serie_providers ||= []

        if providers_filter.any?
          break if (providers_filter & @serie_providers).any?
        else
          break if (@serie_providers & PROVIDERS).any?
        end

        attempts += 1
        raise "No serie found from TMDB" if attempts >= max_attempts
      end

      generate_serie_details(@serie)

      render partial: "serie", locals: {
        serie: @serie,
        serie_title: @serie_title,
        serie_summary: @serie_summary,
        serie_release_date: @serie_release_date,
        serie_language: @serie_language,
        serie_poster_url: @serie_poster_url,
        serie_categories: @serie_categories,
        serie_providers: @serie_providers
      }

    rescue => e
      Rails.logger.warn("pick_serie failed: #{e.message}")

      if selected_media.include?("series") && selected_media.exclude?("movies")
        # Series ONLY selected → show message
        render html: "<div class='no-results'>Aucune série trouvée pour vos filtres. Essayez encore ou changez vos fournisseurs.</div>".html_safe
      else
        # Both or none selected → fallback to pick_movie
        pick_movie
      end
    end
  end

  def movie_page
    generate_movie_credits(@movie)
  end

  def serie_page
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

  def generate_serie
    @serie = nil

    # Try multiple times if the response is empty
    3.times do
      url = "https://api.themoviedb.org/3/tv/top_rated?api_key=#{ENV['TMDB_KEY']}&region=FR&language=fr-FR&page=#{rand(1..500)}"
      response = JSON.parse(URI.open(url).read)

      if response["results"].present?
        series = response["results"]
        @serie = series.sample
        @serie_title = @serie['name']
        @serie_summary = @serie['overview']
        @serie_release_date = @serie['first_air_date'].first(4)
        @serie_language = @serie['original_language']
        @serie_poster_url = "https://image.tmdb.org/t/p/w300#{@serie['poster_path']}"

        break if @serie.present?
      end
    end

    raise "No serie found from TMDB" unless @serie.present?

    return @serie
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

  def generate_serie_details(serie)
    serie_id = serie["id"]
    url = "https://api.themoviedb.org/3/tv/#{serie_id}?api_key=#{ENV['TMDB_KEY']}&language=fr-FR"
    response = JSON.parse(URI.open(url).read)

    if response["genres"].present?
      @serie_categories = response["genres"]
    end
  end

  def generate_movie_providers(movie)
    @movie_providers = []
    movie_id = movie["id"]
    url = "https://api.themoviedb.org/3/movie/#{movie_id}/watch/providers?api_key=#{ENV['TMDB_KEY']}"
    response = JSON.parse(URI.open(url).read)

    if response["results"].present? && response["results"]["FR"].present? && response["results"]["FR"]["flatrate"].present?
      movie_providers = response["results"]["FR"]["flatrate"]
      @movie_providers = movie_providers.map { |provider| provider["provider_name"] }
    end
  end

  def generate_serie_providers(serie)
    raise "No serie given" if serie.nil?

    @serie_providers = []
    serie_id = serie["id"]
    url = "https://api.themoviedb.org/3/tv/#{serie_id}/watch/providers?api_key=#{ENV['TMDB_KEY']}"
    response = JSON.parse(URI.open(url).read)

    if response["results"].present? && response["results"]["FR"].present? && response["results"]["FR"]["flatrate"].present?
      serie_providers = response["results"]["FR"]["flatrate"]
      @serie_providers = serie_providers.map { |provider| provider["provider_name"] }
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
