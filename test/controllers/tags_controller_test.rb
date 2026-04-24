require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tag = tags(:one)
    @user = create_user
    sign_in_as(@user)
  end

  test "should get index" do
    get tags_url

    assert_response :success
  end

  test "should get new" do
    get new_tag_url

    assert_response :success
  end

  test "should create tag" do
    assert_difference("Tag.count") do
      post tags_url, params: { tag: { epc: @tag.epc, pc: @tag.pc } }
    end

    assert_redirected_to tag_url(Tag.last)
  end

  test "should show tag" do
    get tag_url(@tag)

    assert_response :success
  end

  test "should get edit" do
    get edit_tag_url(@tag)

    assert_response :success
  end

  test "should update tag" do
    patch tag_url(@tag), params: { tag: { epc: @tag.epc, pc: @tag.pc } }

    assert_redirected_to tag_url(@tag)
  end

  test "should destroy tag" do
    assert_difference("Tag.count", -1) do
      delete tag_url(@tag)
    end

    assert_redirected_to tags_url
  end

  test "authorize endpoint returns authorized for mapped antenna" do
    tag = Tag.create!(epc: "E2000017DEAD00DEADBEEFFA")
    tag.authorizations << authorizations(:one)
    api_key = ApiKey.create!(bearer: authorizer_apps(:one))

    get authorize_tag_url(tag.epc, format: :json),
      params: { mac: readers(:one).mac_address, antenna: 1 },
      headers: { "Authorization" => "Bearer #{api_key.token}" }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "authorized", body["response"]
  end

  test "authorize endpoint returns unauthorized for mapped antenna" do
    tag = Tag.create!(epc: "E2000017DEAD00DEADBEEFFB")
    api_key = ApiKey.create!(bearer: authorizer_apps(:one))

    get authorize_tag_url(tag.epc, format: :json),
      params: { mac: readers(:one).mac_address, antenna: 1 },
      headers: { "Authorization" => "Bearer #{api_key.token}" }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "unauthorized", body["response"]
  end

  test "authorize endpoint returns record_only for nil authorization mapping" do
    tag = Tag.create!(epc: "E2000017DEAD00DEADBEEFFC")
    api_key = ApiKey.create!(bearer: authorizer_apps(:one))

    get authorize_tag_url(tag.epc, format: :json),
      params: { mac: readers(:one).mac_address, antenna: 2 },
      headers: { "Authorization" => "Bearer #{api_key.token}" }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "record_only", body["response"]
  end

  test "authorize endpoint returns record_only when antenna mapping is missing" do
    tag = Tag.create!(epc: "E2000017DEAD00DEADBEEFFD")
    api_key = ApiKey.create!(bearer: authorizer_apps(:one))

    get authorize_tag_url(tag.epc, format: :json),
      params: { mac: readers(:one).mac_address, antenna: 99 },
      headers: { "Authorization" => "Bearer #{api_key.token}" }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "record_only", body["response"]
  end

  test "authorize endpoint returns forbidden when mac is outside bearer scope" do
    tag = Tag.create!(epc: "E2000017DEAD00DEADBEEFFE")
    api_key = ApiKey.create!(bearer: authorizer_apps(:one))

    get authorize_tag_url(tag.epc, format: :json),
      params: { mac: readers(:two).mac_address, antenna: 1 },
      headers: { "Authorization" => "Bearer #{api_key.token}" }

    assert_response :forbidden
  end
end
