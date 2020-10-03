class AddDescriptionToTags < ActiveRecord::Migration[6.0]
  def change
    add_column :tags, :description, :string
  end
end
