class AddLastSeenAtToTags < ActiveRecord::Migration[6.0]
  def change
    add_column :tags, :last_seen_at, :datetime
  end
end
