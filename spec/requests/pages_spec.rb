require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /home" do
    it "affiche une image de poster sur la page" do
      get root_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("https://image.tmdb.org/t/p/w500/")
    end
  end
end
