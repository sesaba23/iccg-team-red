Rails.application.routes.draw do
  resources :sync_games_managers
  resources :queued_players
  resources :multiplayer_queues
  resources :lines
  resources :documents
  resources :whiteboards
  resources :games
  resources :judges
  resources :guessers
  resources :readers do
    member do
      get 'ask'
    end
  end
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
  get '/start-new-game', to: 'waiting_players#index'

  # Add automatically RESTFul actions to operate with Users
  resources :users

  get 'sessions/new'
  
  resources :documents do
    resources :games
    resources :whiteboards
  end

  #  Add additional routes to the seven routes created by resources
  resources :multiplayer_queues do
    member do
      get 'enqueue'
      get 'wait'
      get 'join'
      get 'quit'
    end
  end

  resources :games do
    member do
      get 'game_over'
    end
    resources :readers do
      member do
        get 'ask'
        get 'answer'
        get 'waiting_for_question'
        get 'review'
      end
    end
    resources :guessers do
      member do
        get 'ask'
        get 'answer'
        get 'waiting_for_question'
        get 'review'
      end
    end
    resources :judges do
      member do
        get 'waiting_for_question'
        get 'waiting_for_answers'
        get 'judging'
      end
    end
  end
  

end
