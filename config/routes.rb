Rails.application.routes.draw do
  resources :readers
  resources :authorizations
  resources :users
  resources :tag_types
  resources :tags do
    member do
      get "authorize"
    end
  end
  resources :tagscans
  post 'tagscans/:event_id/photo', to: 'tagscans#upload_photo', as: :tagscan_photo
  resource :settings, only: [ :edit, :update ] do
    collection do
      post :purge_images
    end
  end
  # resources :api_keys, path: 'api-keys', only: %i[index new create destroy]
  resources :api_keys

  root "tags#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
