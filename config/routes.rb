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
  # root 'application#hello'

  root 'static_pages#home'
  # This pattern routes a GET request for the URL /help
  # to the help action in the Static Pages controller
  get  '/help', to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup',  to: 'users#new'
  get  '/login',   to: 'sessions#new'
  post '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  get  '/waiting-players',   to: 'waiting_players#waiting'
  get '/principal', to: 'games#index'

  # Add automatically RESTFul actions to operate with Users
  resources :users

  get 'sessions/new'
  

  

end
