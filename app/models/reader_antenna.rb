class ReaderAntenna < ApplicationRecord
  belongs_to :reader
  belongs_to :authorization, optional: true

  validates :antenna, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :antenna, uniqueness: { scope: :reader_id }
end