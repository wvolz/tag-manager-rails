require "test_helper"

class ClassifyTagscanImageJobTest < ActiveJob::TestCase
  test "stores classification result on the tagscan" do
    tagscan = Tagscan.create!(tag: tags(:one), received_at: Time.current, image_classification_status: "queued")
    tagscan.image.attach(io: StringIO.new("img"), filename: "test.jpg", content_type: "image/jpeg")

    CodeProjectAi::ObjectDetectionService.transport_override = lambda do |**|
      {
        success: true,
        predictions: [ { label: "person", confidence: 0.88 } ]
      }.to_json
    end

    ClassifyTagscanImageJob.perform_now(tagscan.id)

    tagscan.reload
    assert_equal "classified", tagscan.image_classification_status
    assert tagscan.contains_person
    assert_equal 0.88, tagscan.person_confidence.to_f
    assert_nil tagscan.image_classification_error
  ensure
    CodeProjectAi::ObjectDetectionService.transport_override = nil
  end

  test "skips already classified images unless forced" do
    tagscan = Tagscan.create!(
      tag: tags(:one),
      received_at: Time.current,
      image_classification_status: "classified",
      contains_person: true,
      person_confidence: 0.95
    )
    tagscan.image.attach(io: StringIO.new("img"), filename: "test.jpg", content_type: "image/jpeg")

    CodeProjectAi::ObjectDetectionService.transport_override = lambda do |**|
      raise "should not be called"
    end

    ClassifyTagscanImageJob.perform_now(tagscan.id)

    assert_equal 0.95, tagscan.reload.person_confidence.to_f
  ensure
    CodeProjectAi::ObjectDetectionService.transport_override = nil
  end
end