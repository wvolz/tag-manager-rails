class ApplicationController < ActionController::Base
    include Pagy::Backend

    protect_from_forgery with: :exception, unless: -> { request.format.json? }
    #before_action :config_timezone

    private

    #def config_timezone
    #    Time.zone = 'America/Denver'
    #end
end
