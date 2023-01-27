Rails.application.routes.draw do
  resources :authorizations
  resources :users
  resources :tag_types
  resources :tags do
      member do
          get 'authorize'
      end
  end
  resources :tagscans
  #resources :api_keys, path: 'api-keys', only: %i[index new create destroy]
  resources :api_keys
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
