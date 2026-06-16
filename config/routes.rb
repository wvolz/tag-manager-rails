Rails.application.routes.draw do
  get "company_prefix_maps/index"
  get "company_prefix_maps/new"
  get "company_prefix_maps/create"
  get "company_prefix_maps/edit"
  get "company_prefix_maps/update"
  get "company_prefix_maps/destroy"
  resource :authorizer_app, only: [ :show, :edit, :update ]
  resources :readers
  resources :authorizations
  resources :users
  resources :tag_types
  resources :company_prefix_maps
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
      post :classify_unclassified_images
      post :reclassify_images
    end
  end
  # resources :api_keys, path: 'api-keys', only: %i[index new create destroy]
  resources :api_keys

  root "tags#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
