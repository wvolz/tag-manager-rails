class PurgeTagscanImagesJob < ApplicationJob
  queue_as :default

  def perform(force: false)
    unless force || Setting.image_purge_enabled?
      logger.info "PurgeTagscanImagesJob: skipped (purge disabled)"
      return
    end

    retention_days = Setting.image_retention_days
    candidates = Tagscan.purgeable_images(retention_days)
    count = 0

    candidates.find_each do |tagscan|
      tagscan.image.purge
      count += 1
    end

    logger.info "PurgeTagscanImagesJob: purged #{count} image(s) older than #{retention_days} day(s)"
  end
end
