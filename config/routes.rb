Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      post '/login', to: 'auth#create'
      get '/profile', to: 'users#profile'
      get '/users/:username/novels', to: 'users#show'
      post '/users/:user/submit-sprint', to: 'users#sprint'
      get '/users/:user/:novel', to: 'users#chapters'
      post '/users/:user/submit-novel', to: 'users#new_novel'
      delete '/users/:user/:novel', to: 'users#delete_novel'
      get '/users/:user/:novel/stats', to: 'users#stats'
      put '/users/:user/update-novel', to: 'users#update_sprint'
    end
  end
end
