class AddSortIndexesToTags < ActiveRecord::Migration[8.0]
  def change
    add_index :tags, [:created_at, :id]
    add_index :tags, [:updated_at, :id]
  end
end
