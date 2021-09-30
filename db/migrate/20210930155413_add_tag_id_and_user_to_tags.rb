class AddTagIdAndUserToTags < ActiveRecord::Migration[6.1]
  def change
    add_column :tags, :tid, :string, limit: 124, null: true
    add_column :tags, :user_memory, :string, limit: 124, null: true
  end
end
