class CompanyPrefixMap < ApplicationRecord
  validates :decoder, :company_prefix, :company_name, presence: true
  validates :company_prefix, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :decoder, length: { maximum: 64 }
  validates :company_name, length: { maximum: 255 }

  scope :active, -> { where(active: true) }

  class << self
    def lookup(decoder:, company_prefix:)
      return if decoder.blank? || company_prefix.blank?

      active.find_by(decoder:, company_prefix:)
    end
  end
end
