module ApiKeyAuthenticatable
  # from https://keygen.sh/blog/how-to-implement-api-key-authentication-in-rails-without-devise/

  extend ActiveSupport::Concern

  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::HttpAuthentication::Token::ControllerMethods

  attr_reader :current_api_key, :current_bearer

  # rubocop modifications for this file
  # below for api_key lines below that want to convert to an inline block
  # rubocop:disable Performance/MethodObjectAsBlock

  # Use this to raise an error and automatically respond with a 401 HTTP status
  # code when API key authentication fails
  def authenticate_with_api_key!
    @current_bearer = authenticate_or_request_with_http_token(&method(:authenticator))
    # current_user = @current_bearer
  end

  # Use this for optional API key authentication
  def authenticate_with_api_key
    @current_bearer = authenticate_with_http_token(&method(:authenticator))
  end

  def authenticate_with_api_key_json!
    if request.format.json?
      @current_bearer = authenticate_or_request_with_http_token(&method(:authenticator))
      # current_user = @current_bearer
    else
      require_login
    end
  end

  # rubocop:enable Performance/MethodObjectAsBlock

  private

  attr_writer :current_api_key, :current_bearer

  def authenticator(http_token, _options)
    @current_api_key = ApiKey.authenticate_by_token http_token

    current_api_key&.bearer
  end
end
