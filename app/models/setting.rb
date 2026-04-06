class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  IMAGE_RETENTION_DAYS_KEY = "image_retention_days"
  IMAGE_PURGE_ENABLED_KEY  = "image_purge_enabled"

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

    private

    def upsert_setting(key, value)
      record = find_or_initialize_by(key:)
      record.value = value
      record.save!
    end
  end
end
