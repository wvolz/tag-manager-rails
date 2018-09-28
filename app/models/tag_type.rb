class TagType < ApplicationRecord
    has_many :tags

    enum decoder: [:None, :E470]
end
