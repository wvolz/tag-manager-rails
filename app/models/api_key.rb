class ApiKey < ApplicationRecord
  HMAC_SECRET_KEY = Rails.application.credentials.api_key_hmac_secret_key

  belongs_to :bearer, polymorphic: true

  before_create :generate_token_hmac_digest

  # Virtual attribute for raw token value, allowing us to respond with the
  # API key's non-hashed token value. but only directly after creation.

  attr_accessor :token

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
    h["token"] => token if token.present?
    h
  end

  private

  def generate_token_hmac_digest
    if token.blank?
      raise ActiveRecord::RecordInvalid, "token is required"
    end

    digest = OpenSSL::HMAC.hexdigest "SHA256", HMAC_SECRET_KEY, token

    self.token_digest = digest
  end
end
