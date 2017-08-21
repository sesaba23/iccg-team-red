Rails.application.routes.draw do
  resources :lines
  resources :documents
  resources :whiteboards
  resources :games
  resources :judges
  resources :guessers
  resources :readers
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # Delete when neccessary. Just to check first deployment on Heroku
  root 'application#hello'
end
