json.extract! reader, :id, :name, :location, :created_at, :updated_at
json.url reader_url(reader, format: :json)
