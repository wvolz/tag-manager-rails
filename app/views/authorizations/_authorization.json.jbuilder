json.extract! authorization, :id, :name, :created_at, :updated_at
json.url authorization_url(authorization, format: :json)
