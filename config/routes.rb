Rails.application.routes.draw do
  root to: "pages#home"
  post "/pick_movie", to: "pages#pick_movie"
  get "/movie_details", to: "pages#movie_details"
end
