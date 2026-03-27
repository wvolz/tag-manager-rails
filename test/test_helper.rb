ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
require "rails/test_help"

module AuthenticationTestHelper
  DEFAULT_TEST_PASSWORD = "Password123!".freeze

  def create_user(admin: false, password: DEFAULT_TEST_PASSWORD)
    User.create!(
      email: "user-#{SecureRandom.hex(4)}@example.com",
      password:,
      password_confirmation: password,
      admin:
    )
  end

  def sign_in_as(user, password: DEFAULT_TEST_PASSWORD)
    post session_url, params: { session: { email: user.email, password: } }
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  include AuthenticationTestHelper
end
