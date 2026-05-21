require "test_helper"

module CodeProjectAi
  class ObjectDetectionServiceTest < ActiveSupport::TestCase
    test "classify maps people vehicles and animals from predictions" do
      tagscan = Tagscan.create!(tag: tags(:one), received_at: Time.current)
      tagscan.image.attach(
        io: File.open(Rails.root.join("test/fixtures/files/test.jpg"), "rb"),
        filename: "test.jpg",
        content_type: "image/jpeg"
      )

      observed_content_type = nil
      observed_body = nil
      transport = lambda do |uri:, body:, content_type:|
        observed_content_type = content_type
        observed_body = body
        assert uri.to_s.include?("/v1/vision/detection")

        {
          success: true,
          predictions: [
            { label: "person", confidence: 0.91, x_min: 1, y_min: 2, x_max: 3, y_max: 4 },
            { label: "car", confidence: 0.77, x_min: 5, y_min: 6, x_max: 7, y_max: 8 },
            { label: "dog", confidence: 0.66, x_min: 9, y_min: 10, x_max: 11, y_max: 12 }
          ]
        }.to_json
      end

      result = ObjectDetectionService.new(transport:).classify(tagscan)

      assert_equal "classified", result[:status]
      assert result[:contains_person]
      assert result[:contains_vehicle]
      assert result[:contains_animal]
      assert_equal 0.91, result[:person_confidence]
      assert_equal 0.77, result[:vehicle_confidence]
      assert_equal 0.66, result[:animal_confidence]
      assert_equal 3, result[:payload]["predictions"].size
      assert_includes observed_content_type, "multipart/form-data"
      assert_includes observed_body, "name=\"min_confidence\""
    end

    test "classify returns failed when provider reports an error" do
      tagscan = Tagscan.create!(tag: tags(:one), received_at: Time.current)
      tagscan.image.attach(io: StringIO.new("img"), filename: "test.jpg", content_type: "image/jpeg")

      transport = ->(**) { { success: false, error: "model offline" }.to_json }

      result = ObjectDetectionService.new(transport:).classify(tagscan)

      assert_equal "failed", result[:status]
      assert_equal "model offline", result[:error]
    end
  end
end