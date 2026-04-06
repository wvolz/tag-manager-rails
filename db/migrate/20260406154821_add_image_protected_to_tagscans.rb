class AddImageProtectedToTagscans < ActiveRecord::Migration[8.0]
  def change
    add_column :tagscans, :image_protected, :boolean, default: false, null: false
  end
end
