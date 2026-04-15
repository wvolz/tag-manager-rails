require "test_helper"

class TagscansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tagscan = tagscans(:one)
    @user = create_user
    sign_in_as(@user)
  end

  test "should get index" do
    get tagscans_url

    assert_response :success
  end

  test "should get new" do
    get new_tagscan_url

    assert_response :success
  end

  test "should create tagscan" do
    assert_difference("Tagscan.count") do
      post tagscans_url,
        params: { tagscan: { antenna: @tagscan.antenna, rssi: @tagscan.rssi, tag_epc: @tagscan.tag_epc, tag_pc: @tagscan.tag_pc,
                             received_at: Time.current, event_id: SecureRandom.uuid } }
    end

    assert_redirected_to tagscan_url(Tagscan.last)
  end

  test "should show tagscan" do
    get tagscan_url(@tagscan)

    assert_response :success
  end

  test "should get edit" do
    get edit_tagscan_url(@tagscan)

    assert_response :success
  end

  test "should update tagscan" do
    patch tagscan_url(@tagscan),
      params: { tagscan: { antenna: @tagscan.antenna, rssi: @tagscan.rssi, tag_epc: @tagscan.tag_epc, tag_pc: @tagscan.tag_pc,
                           received_at: @tagscan.received_at, event_id: @tagscan.event_id } }

    assert_redirected_to tagscan_url(@tagscan)
  end

  test "should destroy tagscan" do
    assert_difference("Tagscan.count", -1) do
      delete tagscan_url(@tagscan)
    end

    assert_redirected_to tagscans_url
  end

  test "should protect tagscan image" do
    patch tagscan_url(@tagscan), params: { tagscan: { image_protected: true } }
    assert_redirected_to tagscan_url(@tagscan)
    assert @tagscan.reload.image_protected?
  end

  test "should unprotect tagscan image" do
    @tagscan.update!(image_protected: true)
    patch tagscan_url(@tagscan), params: { tagscan: { image_protected: false } }
    assert_redirected_to tagscan_url(@tagscan)
    assert_not @tagscan.reload.image_protected?
  end

  # upload_photo tests

  test "should upload photo to tagscan" do
    api_key = ApiKey.create!(bearer: @user)
    photo = fixture_file_upload("test.jpg", "image/jpeg")

    post tagscan_photo_url(@tagscan.event_id),
      params: { photo: photo },
      headers: { "Authorization" => "Bearer #{api_key.token}" }

    assert_response :created
    assert @tagscan.reload.image.attached?
  end

  test "should reject photo upload when image already attached" do
    @tagscan.image.attach(io: StringIO.new("existing"), filename: "old.jpg", content_type: "image/jpeg")
    api_key = ApiKey.create!(bearer: @user)
    photo = fixture_file_upload("test.jpg", "image/jpeg")

    post tagscan_photo_url(@tagscan.event_id),
      params: { photo: photo },
      headers: { "Authorization" => "Bearer #{api_key.token}" }

    assert_response :conflict
  end

  test "should return 404 for unknown event_id on photo upload" do
    api_key = ApiKey.create!(bearer: @user)
    photo = fixture_file_upload("test.jpg", "image/jpeg")

    post tagscan_photo_url("nonexistent-event-id"),
      params: { photo: photo },
      headers: { "Authorization" => "Bearer #{api_key.token}" }

    assert_response :not_found
  end

  test "should reject photo upload without api key" do
    photo = fixture_file_upload("test.jpg", "image/jpeg")

    post tagscan_photo_url(@tagscan.event_id),
      params: { photo: photo }

    assert_response :unauthorized
  end
end
