class AuthorizerApp < ApplicationRecord
  has_many :api_keys, as: :bearer, dependent: :destroy
  has_many :readers, dependent: :destroy

  validates :name, presence: true
end