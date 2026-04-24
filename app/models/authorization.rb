class Authorization < ApplicationRecord
  has_and_belongs_to_many :tags
  has_many :reader_antennas, dependent: :nullify
end
