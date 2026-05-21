class PurgeTagscanImagesJob < ApplicationJob
  queue_as :default

  def perform(force: false)
    unless force || Setting.image_purge_enabled?
      logger.info "PurgeTagscanImagesJob: skipped (purge disabled)"
      return
    end

    retention_days = Setting.image_retention_days
    require_no_relevant_detection = Setting.image_purge_without_relevant_detections_enabled?
    relevant_min_confidence = Setting.image_purge_without_relevant_detections_min_confidence
    candidates = Tagscan.purgeable_images(
      retention_days,
      require_no_relevant_detection:,
      relevant_min_confidence:
    )
    count = 0

    candidates.find_each do |tagscan|
      tagscan.image.purge
      count += 1
    end

    logger.info(
      "PurgeTagscanImagesJob: purged #{count} image(s) older than #{retention_days} day(s)" \
      " (require_no_relevant_detection=#{require_no_relevant_detection}, min_confidence=#{relevant_min_confidence})"
    )
  end
end
