class ApplicationController < ActionController::Base
  include Clearance::Controller
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  # before_action :config_timezone
  before_action :require_login

  private

  def require_admin
    unless current_user&.admin?
      respond_to do |format|
        format.html { redirect_to root_path, alert: "You must be an administrator to access this page." }
        format.json { render json: { error: 'Forbidden' }, status: :forbidden }
      end
    end
  end
end
