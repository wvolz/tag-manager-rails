class CreateJoinTableTagAuthorization < ActiveRecord::Migration[5.1]
  def change
    create_join_table :tags, :authorizations do |t|
      # t.index [:tag_id, :authorization_id]
      # t.index [:authorization_id, :tag_id]
    end
  end
end
