class ApiKey < ApplicationRecord
  HMAC_SECRET_KEY = Rails.application.credentials.api_key_hmac_secret_key

  belongs_to :bearer, polymorphic: true

  before_create :generate_token_hmac_digest

  # Virtual attribute for raw token value, allowing us to respond with the
  # API key's non-hashed token value, but only directly after creation.

  attr_accessor :token, :bearer_string

  before_validation :assign_bearer_from_string

  def self.authenticate_by_token!(token)
    digest = OpenSSL::HMAC.hexdigest "SHA256", HMAC_SECRET_KEY, token
    find_by! token_digest: digest
  end

  def self.authenticate_by_token(token)
    authenticate_by_token! token
  rescue ActiveRecord::RecordNotFound
    nil
  end

  # Add virtual token attribute to serializable attributes, and exclude
  # the token's HMAC digest
  def serializable_hash(options = nil)
    h = super options.merge(except: "token_digest")
    h.merge! 'token' => token if token.present?
    h
  end

  private

  def assign_bearer_from_string
    return unless bearer_string.present?
    b_type, b_id = bearer_string.split('_')
    # Validate the models just to be safe
    if ['User', 'Reader'].include?(b_type)
      self.bearer_type = b_type
      self.bearer_id = b_id
    end
  end

  def generate_token_hmac_digest
    self.token = SecureRandom.hex(32) if self.token.blank?

    digest = OpenSSL::HMAC.hexdigest "SHA256", HMAC_SECRET_KEY, token

    self.token_digest = digest
  end
end
