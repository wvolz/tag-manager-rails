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
end
