# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Default image purge settings
Setting.find_or_create_by(key: Setting::IMAGE_PURGE_ENABLED_KEY) { |s| s.value = "false" }
Setting.find_or_create_by(key: Setting::IMAGE_RETENTION_DAYS_KEY) { |s| s.value = "30" }

# Default machine bearer for API keys used by authorizer services.
AuthorizerApp.find_or_create_by!(name: "Primary Authorizer") do |app|
  app.description = "Default authorizer app"
end
