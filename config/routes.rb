Rails.application.routes.draw do
  resources :authorizations
  resources :tag_types
  resources :tags do
      member do
          get 'authorize'
      end
  end
  resources :tagscans
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
