Rails.application.routes.draw do
  root 'home#index'

  get '/:register', to: 'register#index'
end
