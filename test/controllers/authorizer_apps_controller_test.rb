require "test_helper"

class AuthorizerAppsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @authorizer_app = authorizer_apps(:one)
  end

  test "admin can view authorizer app" do
    admin = create_user(admin: true)
    sign_in_as(admin)

    get authorizer_app_url

    assert_response :success
  end

  test "non-admin is redirected from authorizer app" do
    user = create_user(admin: false)
    sign_in_as(user)

    get authorizer_app_url

    assert_redirected_to root_url
  end
end
