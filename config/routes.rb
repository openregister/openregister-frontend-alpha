Rails.application.routes.draw do
  root 'home#index'

  resources :registers, except: [:show]
  get '/:register', to: 'registers#show'
  post '/:register', to: 'registers#show'
  get '/:register/entries', to: 'registers#entries'
  get '/:register/get_data', to: 'registers#get_data'
end
