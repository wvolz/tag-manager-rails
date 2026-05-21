require "test_helper"

class PurgeTagscanImagesJobTest < ActiveJob::TestCase
  setup do
    Setting.image_retention_days = 30
  end

  test "skips purge when disabled and not forced" do
    Setting.image_purge_enabled = false
    old_scan = Tagscan.create!(tag: tags(:one), received_at: 100.days.ago)
    old_scan.image.attach(io: StringIO.new("img"), filename: "x.jpg", content_type: "image/jpeg")

    PurgeTagscanImagesJob.perform_now(force: false)

    assert old_scan.reload.image.attached?
  end

  test "purges old unprotected images when enabled" do
    Setting.image_purge_enabled = true
    old_scan = Tagscan.create!(tag: tags(:one), received_at: 100.days.ago)
    old_scan.image.attach(io: StringIO.new("img"), filename: "x.jpg", content_type: "image/jpeg")

    PurgeTagscanImagesJob.perform_now

    assert_not old_scan.reload.image.attached?
  end

  test "purges when forced even if disabled" do
    Setting.image_purge_enabled = false
    old_scan = Tagscan.create!(tag: tags(:one), received_at: 100.days.ago)
    old_scan.image.attach(io: StringIO.new("img"), filename: "x.jpg", content_type: "image/jpeg")

    PurgeTagscanImagesJob.perform_now(force: true)

    assert_not old_scan.reload.image.attached?
  end

  test "does not purge protected images even when forced" do
    Setting.image_purge_enabled = false
    old_scan = Tagscan.create!(tag: tags(:one), received_at: 100.days.ago, image_protected: true)
    old_scan.image.attach(io: StringIO.new("img"), filename: "x.jpg", content_type: "image/jpeg")

    PurgeTagscanImagesJob.perform_now(force: true)

    assert old_scan.reload.image.attached?
  end

  test "does not purge recent images" do
    Setting.image_purge_enabled = true
    recent_scan = Tagscan.create!(tag: tags(:one), received_at: 1.day.ago)
    recent_scan.image.attach(io: StringIO.new("img"), filename: "x.jpg", content_type: "image/jpeg")

    PurgeTagscanImagesJob.perform_now

    assert recent_scan.reload.image.attached?
  end

  test "does not purge unclassified images when detection-aware purge rule is enabled" do
    Setting.image_purge_enabled = true
    Setting.image_purge_without_relevant_detections_enabled = true
    Setting.image_purge_without_relevant_detections_min_confidence = 0.6
    old_scan = Tagscan.create!(tag: tags(:one), received_at: 100.days.ago)
    old_scan.image.attach(io: StringIO.new("img"), filename: "x.jpg", content_type: "image/jpeg")

    PurgeTagscanImagesJob.perform_now

    assert old_scan.reload.image.attached?
  end

  test "purges classified images with no relevant detections when detection-aware purge rule is enabled" do
    Setting.image_purge_enabled = true
    Setting.image_purge_without_relevant_detections_enabled = true
    Setting.image_purge_without_relevant_detections_min_confidence = 0.6
    old_scan = Tagscan.create!(
      tag: tags(:one),
      received_at: 100.days.ago,
      image_classification_status: "classified",
      contains_person: false,
      contains_vehicle: false,
      contains_animal: false,
      person_confidence: 0.3,
      vehicle_confidence: 0.2,
      animal_confidence: 0.1
    )
    old_scan.image.attach(io: StringIO.new("img"), filename: "x.jpg", content_type: "image/jpeg")

    PurgeTagscanImagesJob.perform_now

    assert_not old_scan.reload.image.attached?
  end
end
