require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /home" do

    it "displays a movie poster on the home page" do
      get root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("https://image.tmdb.org/t/p/w")
    end

    it "displays the name of the movie director" do
      get root_path
      expect(response.body).to match(/Réalisateur :\s*.+/)
    end

    let(:categories) { ["Science-Fiction", "Thriller", "Aventure", "Action", "Horreur", "Crime", "Familial", "Fantastique", "Drame", "Comédie", "Mystère"] }

    it "displays at least one movie category" do
      get root_path

      category = categories.any? { |category| response.body.include?(category) }
      expect(category).to be_truthy
    end
  end
end
