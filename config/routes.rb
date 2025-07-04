Rails.application.routes.draw do
  root to: "pages#home"

  post "/pick_movie", to: "pages#pick_movie"
  post "/pick_serie", to: "pages#pick_serie"

  get "/movie/:id", to: "pages#movie_page", as: :movie
  get "/serie/:id", to: "pages#serie_page", as: :serie
end
