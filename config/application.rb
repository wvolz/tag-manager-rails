require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TagManagerRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # set cache format to 7.0, prevents rollback to 6.x
    config.active_support.cache_format_version = 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = 'America/Denver'
    # config.eager_load_paths << Rails.root.join("extras")

    # change to match your camera, expects a JPEG image
    config.grabphoto_camera_url = 'http://10.11.50.178/cgi-bin/snapshot.cgi'
  end
end
