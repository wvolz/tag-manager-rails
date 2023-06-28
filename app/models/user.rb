class User < ApplicationRecord
  include Clearance::User

  validates :password, confirmation: true, unless: :skip_password_validation?
  validates :password_confirmation, presence: true, unless: :skip_password_validation?

  has_many :api_keys, as: :bearer
end
