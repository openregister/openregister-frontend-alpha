Rails.application.routes.draw do
  root 'home#index'

  get '/:register', to: 'register#index'
  get '/:register/entries', to: 'register#entries'
end
