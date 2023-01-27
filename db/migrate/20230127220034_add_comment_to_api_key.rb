class AddCommentToApiKey < ActiveRecord::Migration[6.1]
  def change
    add_column :api_keys, :comment, :string
  end
end
