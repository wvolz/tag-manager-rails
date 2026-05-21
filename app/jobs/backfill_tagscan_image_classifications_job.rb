class BackfillTagscanImageClassificationsJob < ApplicationJob
  queue_as :default

  def perform(force: false)
    scope = Tagscan.with_attached_image
    scope = scope.where(image_classification_status: nil) unless force

    scope.find_each do |tagscan|
      tagscan.mark_image_classification_queued!
      ClassifyTagscanImageJob.perform_later(tagscan.id, force:)
    end
  end
end