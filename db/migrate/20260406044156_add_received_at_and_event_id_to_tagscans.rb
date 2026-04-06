class AddReceivedAtAndEventIdToTagscans < ActiveRecord::Migration[8.0]
  def change
    add_column :tagscans, :received_at, :datetime
    add_column :tagscans, :event_id, :string
    add_index :tagscans, :event_id, unique: true

    reversible do |dir|
      dir.up { Tagscan.update_all("received_at = created_at") }
    end
  end
end
