class Reader < ApplicationRecord
  MAC_ADDRESS_FORMAT = /\A(?:[0-9A-F]{2}:){5}[0-9A-F]{2}\z/

  belongs_to :authorizer_app
  has_many :reader_antennas, dependent: :destroy
  has_many :tagscans, dependent: :nullify

  accepts_nested_attributes_for :reader_antennas,
                                allow_destroy: true,
                                reject_if: ->(attrs) {
                                  attrs["id"].blank? && attrs["_destroy"] != "1" && attrs["antenna"].blank?
                                }

  before_validation :normalize_mac_address

  validates :name, presence: true
  validates :mac_address,
            allow_blank: true,
            uniqueness: true,
            format: { with: MAC_ADDRESS_FORMAT, message: "must be uppercase colon-separated (e.g. 00:DE:AD:BE:EF:11)" }

  def self.normalize_mac(value)
    return if value.blank?

    cleaned = value.to_s.strip.upcase.gsub(/[^0-9A-F]/, "")
    return if cleaned.length != 12

    cleaned.scan(/../).join(":")
  end

  private

  def normalize_mac_address
    self.mac_address = self.class.normalize_mac(mac_address)
  end
end
