class User < ApplicationRecord
  include Clearance::User
  
  has_many :api_keys, as: :bearer
end
