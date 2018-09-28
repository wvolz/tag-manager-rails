class AddTagTypeDecoderToTagType < ActiveRecord::Migration[5.1]
  def change
    add_column :tag_types, :decoder, :integer
  end
end
