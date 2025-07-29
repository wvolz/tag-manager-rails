class ApplicationController < ActionController::Base
  include Clearance::Controller
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  # before_action :config_timezone
  before_action :require_login
end
