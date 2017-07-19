Rails.application.routes.draw do
  root 'home#index'

  resources :registers, except: [:show]
  get '/:register', to: 'registers#show'
end
