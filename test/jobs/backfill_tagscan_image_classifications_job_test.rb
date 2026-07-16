require "test_helper"

class BackfillTagscanImageClassificationsJobTest < ActiveJob::TestCase
  test "enqueues classification only for tagscans with attached images" do
    tag_with_image = Tagscan.create!(
      tag: tags(:one),
      received_at: Time.current,
      event_id: SecureRandom.uuid,
      image_classification_status: nil
    )
    tag_with_image.image.attach(io: StringIO.new("img"), filename: "test.jpg", content_type: "image/jpeg")

    tag_without_image = Tagscan.create!(
      tag: tags(:one),
      received_at: Time.current,
      event_id: SecureRandom.uuid,
      image_classification_status: nil
    )

    assert_enqueued_jobs 1, only: ClassifyTagscanImageJob do
      BackfillTagscanImageClassificationsJob.perform_now(force: false)
    end

    assert_equal "queued", tag_with_image.reload.image_classification_status
    assert_nil tag_without_image.reload.image_classification_status
  end
end
