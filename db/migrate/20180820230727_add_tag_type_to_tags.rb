class AddTagTypeToTags < ActiveRecord::Migration[5.1]
  def change
    add_column :tags, :tag_type_id, :integer
  end
end
