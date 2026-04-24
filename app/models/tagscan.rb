class Tagscan < ApplicationRecord
  belongs_to :tag
  belongs_to :reader, optional: true
  has_one_attached :image
  after_create :update_last_seen_time
  scope :by_created, -> { order(received_at: :desc) }
  scope :purgeable_images, ->(cutoff_days) {
    joins(:image_attachment)
      .where(image_protected: false)
      .where("received_at < ?", cutoff_days.days.ago)
  }

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

  private
end
