class ClassifyTagscanImageJob < ApplicationJob
  queue_as :default

  def perform(tagscan_id, force: false)
    tagscan = Tagscan.find(tagscan_id)
    return unless tagscan.image.attached?
    return if tagscan.image_classification_status == "classified" && !force

    tagscan.update!(image_classification_status: "processing", image_classification_error: nil)

    result = CodeProjectAi::ObjectDetectionService.new.classify(tagscan)
    tagscan.apply_image_classification_result!(result)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end