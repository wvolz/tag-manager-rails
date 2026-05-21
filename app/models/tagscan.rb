class Tagscan < ApplicationRecord
  IMAGE_CLASSIFICATION_STATUSES = %w[queued processing classified failed].freeze

  belongs_to :tag
  belongs_to :reader, optional: true
  has_one_attached :image
  after_create :update_last_seen_time
  scope :by_created, -> { order(received_at: :desc) }
  scope :with_image_attachment, -> { joins(:image_attachment) }
  scope :classification_status, ->(status) { where(image_classification_status: status) }
  scope :unclassified_images, -> { with_image_attachment.where(image_classification_status: nil) }
  scope :classified_images, -> { with_image_attachment.where(image_classification_status: "classified") }
  scope :failed_classification_images, -> { with_image_attachment.where(image_classification_status: "failed") }
  scope :containing_person, -> { classified_images.where(contains_person: true) }
  scope :containing_vehicle, -> { classified_images.where(contains_vehicle: true) }
  scope :containing_animal, -> { classified_images.where(contains_animal: true) }
  scope :with_relevant_detection, -> {
    classified_images.where(contains_person: true)
                     .or(classified_images.where(contains_vehicle: true))
                     .or(classified_images.where(contains_animal: true))
  }
  scope :purgeable_images, lambda { |cutoff_days, require_no_relevant_detection: false, relevant_min_confidence: 0.6|
    joins(:image_attachment)
      .where(image_protected: false)
      .where("received_at < ?", cutoff_days.days.ago)
      .yield_self { |relation|
        next relation unless require_no_relevant_detection

        relation.where(image_classification_status: "classified")
                .where(
                  "COALESCE(person_confidence, 0) < :threshold AND COALESCE(vehicle_confidence, 0) < :threshold AND COALESCE(animal_confidence, 0) < :threshold",
                  threshold: relevant_min_confidence
                )
      }
  }

  validates :image_classification_status,
            inclusion: { in: IMAGE_CLASSIFICATION_STATUSES },
            allow_nil: true

  def tag_epc
    tag.try(:epc)
  end

  def tag_pc
    tag.try(:pc)
  end

  def tag_epc=(epc)
    self.tag = Tag.find_or_create_by(epc:) if epc.present?
  end

  # rubocop:disable Naming/MethodParameterName
  def tag_pc=(pc)
    # this doesn't seem very efficient?
    self.tag = Tag.find_by(epc: tag_epc) if pc.present?
    tag.pc = pc
    tag.save
  end
  # rubocop:enable Naming/MethodParameterName

  def update_last_seen_time
    tag.last_seen_at = received_at || DateTime.current
    tag.save
  end

  def image_classification_payload_json
    return {} if image_classification_payload.blank?

    JSON.parse(image_classification_payload)
  rescue JSON::ParserError
    {}
  end

  def image_predictions
    Array(image_classification_payload_json["predictions"])
  end

  def image_detection_summary
    [
      detection_summary_entry(:person, contains_person, person_confidence),
      detection_summary_entry(:vehicle, contains_vehicle, vehicle_confidence),
      detection_summary_entry(:animal, contains_animal, animal_confidence)
    ].compact
  end

  def has_relevant_detection_at_or_above?(threshold)
    [ person_confidence, vehicle_confidence, animal_confidence ].compact.any? { |value| value.to_f >= threshold.to_f }
  end

  def mark_image_classification_queued!
    update!(
      image_classification_status: "queued",
      image_classification_error: nil
    )
  end

  def apply_image_classification_result!(result)
    update!(
      image_classification_status: result.fetch(:status),
      image_classified_at: result[:classified_at],
      image_classification_error: result[:error],
      image_classification_payload: result[:payload]&.to_json,
      contains_person: result.fetch(:contains_person, false),
      contains_vehicle: result.fetch(:contains_vehicle, false),
      contains_animal: result.fetch(:contains_animal, false),
      person_confidence: result[:person_confidence],
      vehicle_confidence: result[:vehicle_confidence],
      animal_confidence: result[:animal_confidence]
    )
  end

  private

  def detection_summary_entry(type, present, confidence)
    return unless present

    { type:, confidence: confidence.to_f }
  end
end
