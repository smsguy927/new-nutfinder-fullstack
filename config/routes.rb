# frozen_string_literal: true

Rails.application.routes.draw do
  get 'passwords/new'
  get 'passwords/create'
  get 'passwords/edit'
  get 'passwords/update'
  resources :board_cards, only: %i[index show create update destroy]
  resources :articles, only: %i[index show]
  resources :cards, only: %i[index show]
  resources :questions, only: %i[index show create update destroy]
  resources :games, only: %i[index show create update]
  resources :users, only: %i[index show create update destroy]
  post '/signup', to: 'users#create'
  post '/login', to: 'sessions#create'
  post '/new-game', to: 'games#create'
  get '/me', to: 'users#show'
  delete '/logout', to: 'sessions#destroy'

  # get '/password/reset', to: 'passwords#new'
  # post '/password/reset', to: 'passwords#create'
  # get '/password/reset/edit', to: 'passwords#edit'
  # patch '/password/reset/edit', to: 'passwords#update'
  post 'forgot_password' => "passwords#forgot"
  post 'reset_password' => "passwords#reset"
  get 'get_current_user' => "sessions#get_current_user"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
