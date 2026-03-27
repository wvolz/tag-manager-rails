require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_user(admin: true)
    @user = create_user
  end

  test "admin should get index" do
    sign_in_as(@admin)

    get users_url

    assert_response :success
  end

  test "user should get own profile" do
    sign_in_as(@user)

    get user_url(@user)

    assert_response :success
  end

  test "admin should get new" do
    sign_in_as(@admin)

    get new_user_url

    assert_response :success
  end

  test "user should get own edit" do
    sign_in_as(@user)

    get edit_user_url(@user)

    assert_response :success
  end

  test "admin should create user" do
    sign_in_as(@admin)

    assert_difference("User.count", 1) do
      post users_url, params: {
        user: {
          email: "new-user@example.com",
          first_name: "New",
          last_name: "User",
          password: "Password123!",
          password_confirmation: "Password123!",
          admin: false
        }
      }
    end

    assert_redirected_to user_url(User.last)
  end

  test "user should update own profile" do
    sign_in_as(@user)

    patch user_url(@user), params: { user: { first_name: "Updated" } }

    assert_redirected_to user_url(@user)
    assert_equal "Updated", @user.reload.first_name
  end

  test "admin should destroy user" do
    sign_in_as(@admin)

    assert_difference("User.count", -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end
end
