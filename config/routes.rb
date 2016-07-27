Rails.application.routes.draw do

  resources :movies, only: [:index]
  resources :sources, only: [:index]

end
