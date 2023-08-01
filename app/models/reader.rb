class Reader < ApplicationRecord
  has_many :api_keys, as: :bearer, dependent: :destroy
end
