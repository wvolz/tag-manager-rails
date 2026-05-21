require "json"
require "net/http"
require "securerandom"
require "set"
require "uri"

module CodeProjectAi
  class ObjectDetectionService
    class_attribute :transport_override, default: nil

    DEFAULT_ENDPOINT = "http://localhost:32168".freeze
    PERSON_LABELS = Set.new(%w[person people human man woman]).freeze
    VEHICLE_LABELS = Set.new(%w[vehicle car truck bus van suv pickup motorcycle motorbike bicycle boat train airplane aeroplane]).freeze
    ANIMAL_LABELS = Set.new(%w[animal bird cat dog horse sheep cow elephant bear zebra giraffe deer fox rabbit squirrel raccoon racoon skunk]).freeze

    def initialize(endpoint: Setting.image_classification_endpoint, min_confidence: Setting.image_classification_min_confidence, transport: nil)
      @endpoint = endpoint.presence || DEFAULT_ENDPOINT
      @min_confidence = min_confidence
      @transport = transport || self.class.transport_override
    end

    def classify(tagscan)
      unless tagscan.image.attached?
        return failure_result("No image attached")
      end

      blob = tagscan.image.blob
      payload = blob.open(tmpdir: Dir.tmpdir) do |file|
        response_body = send_detection_request(
          io: file,
          filename: blob.filename.to_s,
          content_type: blob.content_type.presence || "application/octet-stream"
        )

        JSON.parse(response_body)
      end

      return failure_result(payload["error"] || payload["message"] || "Object detection failed", payload: payload) if payload["success"] == false

      predictions = Array(payload["predictions"])

      success_result(payload:, predictions:)
    rescue JSON::ParserError => error
      failure_result("Invalid response from CodeProject.AI: #{error.message}")
    rescue StandardError => error
      failure_result(error.message)
    end

    private

    attr_reader :endpoint, :min_confidence, :transport

    def success_result(payload:, predictions:)
      normalized_predictions = predictions.filter_map { |prediction| normalize_prediction(prediction) }

      {
        status: "classified",
        classified_at: Time.current,
        error: nil,
        payload: payload,
        contains_person: max_confidence_for(normalized_predictions, PERSON_LABELS).present?,
        contains_vehicle: max_confidence_for(normalized_predictions, VEHICLE_LABELS).present?,
        contains_animal: max_confidence_for(normalized_predictions, ANIMAL_LABELS).present?,
        person_confidence: max_confidence_for(normalized_predictions, PERSON_LABELS),
        vehicle_confidence: max_confidence_for(normalized_predictions, VEHICLE_LABELS),
        animal_confidence: max_confidence_for(normalized_predictions, ANIMAL_LABELS)
      }
    end

    def failure_result(message, payload: nil)
      {
        status: "failed",
        classified_at: Time.current,
        error: message,
        payload: payload,
        contains_person: false,
        contains_vehicle: false,
        contains_animal: false,
        person_confidence: nil,
        vehicle_confidence: nil,
        animal_confidence: nil
      }
    end

    def normalize_prediction(prediction)
      label = prediction["label"].to_s.strip.downcase
      confidence = Float(prediction["confidence"])

      return if label.blank?

      prediction.merge("label" => label, "confidence" => confidence)
    rescue ArgumentError, TypeError
      nil
    end

    def max_confidence_for(predictions, label_set)
      predictions.filter_map do |prediction|
        prediction["confidence"] if label_set.include?(prediction["label"])
      end.max
    end

    def send_detection_request(io:, filename:, content_type:)
      uri = detection_uri
      body, content_type_header = build_multipart_body(io:, filename:, content_type:)

      if transport
        return transport.call(uri:, body:, content_type: content_type_header)
      end

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = content_type_header
      request["Accept"] = "application/json"
      request.body = body

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 30, open_timeout: 10) do |http|
        response = http.request(request)
        raise "CodeProject.AI request failed with #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        response.body
      end
    end

    def build_multipart_body(io:, filename:, content_type:)
      boundary = "----RubyMultipart#{SecureRandom.hex(16)}"
      data = io.read
      body = String.new(encoding: Encoding::BINARY)

      append_multipart_file(body, boundary:, filename:, content_type:, data:)
      append_multipart_field(body, boundary:, name: "min_confidence", value: min_confidence.to_s)
      body << "--#{boundary}--\r\n"

      [ body, "multipart/form-data; boundary=#{boundary}" ]
    end

    def append_multipart_file(body, boundary:, filename:, content_type:, data:)
      body << "--#{boundary}\r\n"
      body << "Content-Disposition: form-data; name=\"image\"; filename=\"#{filename}\"\r\n"
      body << "Content-Type: #{content_type}\r\n\r\n"
      body << data
      body << "\r\n"
    end

    def append_multipart_field(body, boundary:, name:, value:)
      body << "--#{boundary}\r\n"
      body << "Content-Disposition: form-data; name=\"#{name}\"\r\n\r\n"
      body << value
      body << "\r\n"
    end

    def detection_uri
      uri = URI.parse(endpoint)
      return uri if uri.path.include?("/v1/")

      URI.parse("#{endpoint.to_s.sub(%r{/$}, "")}/v1/vision/detection")
    rescue URI::InvalidURIError
      raise "CodeProject.AI endpoint is invalid"
    end
  end
end