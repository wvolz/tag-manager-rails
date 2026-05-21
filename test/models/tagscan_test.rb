require "test_helper"

class TagscanTest < ActiveSupport::TestCase
  test "purgeable_images includes old unprotected scans with images" do
    old_scan = Tagscan.create!(tag: tags(:one), received_at: 100.days.ago)
    old_scan.image.attach(io: StringIO.new("img"), filename: "x.jpg", content_type: "image/jpeg")

    assert_includes Tagscan.purgeable_images(30), old_scan
  end

  test "purgeable_images excludes protected scans" do
    old_scan = Tagscan.create!(tag: tags(:one), received_at: 100.days.ago, image_protected: true)
    old_scan.image.attach(io: StringIO.new("img"), filename: "x.jpg", content_type: "image/jpeg")

    assert_not_includes Tagscan.purgeable_images(30), old_scan
  end

  test "purgeable_images excludes recent scans" do
    recent_scan = Tagscan.create!(tag: tags(:one), received_at: 1.day.ago)
    recent_scan.image.attach(io: StringIO.new("img"), filename: "x.jpg", content_type: "image/jpeg")

    assert_not_includes Tagscan.purgeable_images(30), recent_scan
  end

  test "purgeable_images excludes scans without images" do
    old_scan = Tagscan.create!(tag: tags(:one), received_at: 100.days.ago)

    assert_not_includes Tagscan.purgeable_images(30), old_scan
  end

  test "purgeable_images excludes classified images with relevant detections when rule enabled" do
    Setting.image_purge_without_relevant_detections_enabled = true
    Setting.image_purge_without_relevant_detections_min_confidence = 0.6

    old_scan = Tagscan.create!(
      tag: tags(:one),
      received_at: 100.days.ago,
      image_classification_status: "classified",
      contains_person: true,
      person_confidence: 0.91
    )
    old_scan.image.attach(io: StringIO.new("img"), filename: "x.jpg", content_type: "image/jpeg")

    assert_not_includes(
      Tagscan.purgeable_images(
        30,
        require_no_relevant_detection: true,
        relevant_min_confidence: 0.6
      ),
      old_scan
    )
  end

  test "with_relevant_detection includes animal vehicle or person detections" do
    person_scan = Tagscan.create!(
      tag: tags(:one),
      received_at: Time.current,
      image_classification_status: "classified",
      contains_person: true,
      person_confidence: 0.8
    )
    person_scan.image.attach(io: StringIO.new("img"), filename: "person.jpg", content_type: "image/jpeg")

    blank_scan = Tagscan.create!(tag: tags(:one), received_at: Time.current, image_classification_status: "classified")
    blank_scan.image.attach(io: StringIO.new("img"), filename: "blank.jpg", content_type: "image/jpeg")

    assert_includes Tagscan.with_relevant_detection, person_scan
    assert_not_includes Tagscan.with_relevant_detection, blank_scan
  end
end
