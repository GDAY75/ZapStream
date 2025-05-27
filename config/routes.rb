Rails.application.routes.draw do
  root to: "pages#home"
  get "movie_details", to: "pages#movie_details"
end
