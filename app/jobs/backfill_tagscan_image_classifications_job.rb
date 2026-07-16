class BackfillTagscanImageClassificationsJob < ApplicationJob
  queue_as :default

  def perform(force: false)
    scope = Tagscan.with_attached_image
    scope = scope.where(image_classification_status: nil) unless force
    enqueued = 0
    skipped_missing_image = 0

    scope.find_each do |tagscan|
      unless tagscan.image.attached?
        skipped_missing_image += 1
        next
      end

      tagscan.mark_image_classification_queued!
      ClassifyTagscanImageJob.perform_later(tagscan.id, force:)
      enqueued += 1
    end

    logger.info(
      "BackfillTagscanImageClassificationsJob: enqueued=#{enqueued} skipped_missing_image=#{skipped_missing_image} force=#{force}"
    )
  end
end