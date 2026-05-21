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

  test "should enqueue classification after photo upload when enabled" do
    Setting.image_classification_enabled = true
    api_key = ApiKey.create!(bearer: @user)
    photo = fixture_file_upload("test.jpg", "image/jpeg")

    assert_enqueued_with(job: ClassifyTagscanImageJob, args: [ @tagscan.id ]) do
      post tagscan_photo_url(@tagscan.event_id),
        params: { photo: photo },
        headers: { "Authorization" => "Bearer #{api_key.token}" }
    end

    assert_equal "queued", @tagscan.reload.image_classification_status
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

  test "json create assigns reader by mac and updates reader activity" do
    api_key = ApiKey.create!(bearer: authorizer_apps(:one))
    event_id = SecureRandom.uuid

    assert_difference("Tagscan.count") do
      post tagscans_url(format: :json),
        params: {
          tagscan: {
            tag_epc: "E2000017DEAD00DEADBEEFAB",
            tag_pc: "3000",
            antenna: 1,
            rssi: -45,
            received_at: Time.current,
            event_id: event_id,
            mac: readers(:one).mac_address,
            source_ip: "192.168.0.13",
            reader_name: "RFID Reader",
            hostname: "rfid-BEEF11"
          }
        },
        headers: { "Authorization" => "Bearer #{api_key.token}" }
    end

    assert_response :created
    created = Tagscan.find_by!(event_id: event_id)
    assert_equal readers(:one).id, created.reader_id
    assert_equal "192.168.0.13", readers(:one).reload.source_ip
  end

  test "json create returns forbidden when mac is not in bearer scope" do
    api_key = ApiKey.create!(bearer: authorizer_apps(:one))

    post tagscans_url(format: :json),
      params: {
        tagscan: {
          tag_epc: "E2000017DEAD00DEADBEEFAC",
          tag_pc: "3000",
          antenna: 1,
          rssi: -45,
          received_at: Time.current,
          event_id: SecureRandom.uuid,
          mac: readers(:two).mac_address
        }
      },
      headers: { "Authorization" => "Bearer #{api_key.token}" }

    assert_response :forbidden
  end

  test "json create still works during transition when mac is omitted" do
    api_key = ApiKey.create!(bearer: @user)

    assert_difference("Tagscan.count") do
      post tagscans_url(format: :json),
        params: {
          tagscan: {
            tag_epc: "E2000017DEAD00DEADBEEFAD",
            tag_pc: "3000",
            antenna: 1,
            rssi: -42,
            received_at: Time.current,
            event_id: SecureRandom.uuid
          }
        },
        headers: { "Authorization" => "Bearer #{api_key.token}" }
    end

    assert_response :created
    assert_nil Tagscan.last.reader_id
  end

  test "index filters by relevant detection" do
    matching_tag = Tag.create!(epc: "E20000000000000000000001")
    non_matching_tag = Tag.create!(epc: "E20000000000000000000002")

    matching_scan = Tagscan.create!(
      tag: matching_tag,
      antenna: 1,
      rssi: -40,
      received_at: Time.current,
      event_id: SecureRandom.uuid,
      image_classification_status: "classified",
      contains_person: true,
      person_confidence: 0.95
    )
    matching_scan.image.attach(io: StringIO.new("img"), filename: "match.jpg", content_type: "image/jpeg")

    non_matching_scan = Tagscan.create!(
      tag: non_matching_tag,
      antenna: 1,
      rssi: -41,
      received_at: Time.current,
      event_id: SecureRandom.uuid,
      image_classification_status: "classified"
    )
    non_matching_scan.image.attach(io: StringIO.new("img"), filename: "other.jpg", content_type: "image/jpeg")

    get tagscans_url, params: { detection: "person", with_image: "1" }

    assert_response :success
    assert_includes @response.body, matching_tag.epc
    assert_not_includes @response.body, non_matching_tag.epc
  end
end
