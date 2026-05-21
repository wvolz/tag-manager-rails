class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  IMAGE_RETENTION_DAYS_KEY = "image_retention_days"
  IMAGE_PURGE_ENABLED_KEY  = "image_purge_enabled"
  IMAGE_CLASSIFICATION_ENABLED_KEY = "image_classification_enabled"
  IMAGE_CLASSIFICATION_ENDPOINT_KEY = "image_classification_endpoint"
  IMAGE_CLASSIFICATION_MIN_CONFIDENCE_KEY = "image_classification_min_confidence"
  IMAGE_PURGE_WITHOUT_RELEVANT_DETECTIONS_ENABLED_KEY = "image_purge_without_relevant_detections_enabled"
  IMAGE_PURGE_WITHOUT_RELEVANT_DETECTIONS_MIN_CONFIDENCE_KEY = "image_purge_without_relevant_detections_min_confidence"

  class << self
    def image_retention_days
      find_by(key: IMAGE_RETENTION_DAYS_KEY)&.value&.to_i || 30
    end

    def image_retention_days=(days)
      upsert_setting(IMAGE_RETENTION_DAYS_KEY, days.to_s)
    end

    def image_purge_enabled?
      find_by(key: IMAGE_PURGE_ENABLED_KEY)&.value == "true"
    end

    def image_purge_enabled=(bool)
      upsert_setting(IMAGE_PURGE_ENABLED_KEY, bool ? "true" : "false")
    end

    def image_classification_enabled?
      find_by(key: IMAGE_CLASSIFICATION_ENABLED_KEY)&.value == "true"
    end

    def image_classification_enabled=(bool)
      upsert_setting(IMAGE_CLASSIFICATION_ENABLED_KEY, bool ? "true" : "false")
    end

    def image_classification_endpoint
      value = find_by(key: IMAGE_CLASSIFICATION_ENDPOINT_KEY)&.value
      value.presence || ENV["CODEPROJECT_AI_ENDPOINT"].presence
    end

    def image_classification_endpoint=(value)
      if value.blank?
        find_by(key: IMAGE_CLASSIFICATION_ENDPOINT_KEY)&.destroy!
        return
      end

      upsert_setting(IMAGE_CLASSIFICATION_ENDPOINT_KEY, value.to_s.strip)
    end

    def image_classification_min_confidence
      value = find_by(key: IMAGE_CLASSIFICATION_MIN_CONFIDENCE_KEY)&.value
      clamp_confidence(value, default: 0.4)
    end

    def image_classification_min_confidence=(value)
      upsert_setting(IMAGE_CLASSIFICATION_MIN_CONFIDENCE_KEY, clamp_confidence(value, default: 0.4).to_s)
    end

    def image_purge_without_relevant_detections_enabled?
      find_by(key: IMAGE_PURGE_WITHOUT_RELEVANT_DETECTIONS_ENABLED_KEY)&.value == "true"
    end

    def image_purge_without_relevant_detections_enabled=(bool)
      upsert_setting(IMAGE_PURGE_WITHOUT_RELEVANT_DETECTIONS_ENABLED_KEY, bool ? "true" : "false")
    end

    def image_purge_without_relevant_detections_min_confidence
      value = find_by(key: IMAGE_PURGE_WITHOUT_RELEVANT_DETECTIONS_MIN_CONFIDENCE_KEY)&.value
      clamp_confidence(value, default: 0.6)
    end

    def image_purge_without_relevant_detections_min_confidence=(value)
      upsert_setting(
        IMAGE_PURGE_WITHOUT_RELEVANT_DETECTIONS_MIN_CONFIDENCE_KEY,
        clamp_confidence(value, default: 0.6).to_s
      )
    end

    private

    def upsert_setting(key, value)
      record = find_or_initialize_by(key:)
      record.value = value
      record.save!
    end

    def clamp_confidence(value, default:)
      Float(value || default)
    rescue ArgumentError, TypeError
      default
    else
      Float(value || default).clamp(0.0, 1.0)
    end
  end
end
