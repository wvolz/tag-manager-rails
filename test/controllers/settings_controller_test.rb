require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user(admin: true)
    sign_in_as(@user)
  end

  test "should get edit" do
    get edit_settings_url
    assert_response :success
  end

  test "should update retention days" do
    patch settings_url, params: { settings: { image_retention_days: 60, image_purge_enabled: "0" } }
    assert_redirected_to edit_settings_url
    assert_equal 60, Setting.image_retention_days
  end

  test "should enable purge via update" do
    patch settings_url, params: { settings: { image_retention_days: 30, image_purge_enabled: "1" } }
    assert_redirected_to edit_settings_url
    assert Setting.image_purge_enabled?
  end

  test "should disable purge when checkbox unchecked" do
    Setting.image_purge_enabled = true
    patch settings_url, params: { settings: { image_retention_days: 30, image_purge_enabled: "0" } }
    assert_redirected_to edit_settings_url
    assert_not Setting.image_purge_enabled?
  end

  test "should update classification settings" do
    patch settings_url, params: {
      settings: {
        image_retention_days: 30,
        image_purge_enabled: "0",
        image_classification_enabled: "1",
        image_classification_endpoint: "http://cpai.local:32168",
        image_classification_min_confidence: "0.55",
        image_purge_without_relevant_detections_enabled: "1",
        image_purge_without_relevant_detections_min_confidence: "0.7"
      }
    }

    assert_redirected_to edit_settings_url
    assert Setting.image_classification_enabled?
    assert_equal "http://cpai.local:32168", Setting.image_classification_endpoint
    assert_equal 0.55, Setting.image_classification_min_confidence
    assert Setting.image_purge_without_relevant_detections_enabled?
    assert_equal 0.7, Setting.image_purge_without_relevant_detections_min_confidence
  end

  test "should enqueue purge job on purge_images" do
    assert_enqueued_with(job: PurgeTagscanImagesJob) do
      post purge_images_settings_url
    end
    assert_redirected_to edit_settings_url
  end

  test "should enqueue backfill job for unclassified images" do
    assert_enqueued_with(job: BackfillTagscanImageClassificationsJob, args: [ { force: false } ]) do
      post classify_unclassified_images_settings_url
    end

    assert_redirected_to edit_settings_url
  end

  test "should enqueue full reclassification job" do
    assert_enqueued_with(job: BackfillTagscanImageClassificationsJob, args: [ { force: true } ]) do
      post reclassify_images_settings_url
    end

    assert_redirected_to edit_settings_url
  end

  test "requires login" do
    delete sign_out_path
    get edit_settings_url
    assert_redirected_to sign_in_url
  end
end
