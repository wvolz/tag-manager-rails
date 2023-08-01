class ChangeTagPcLength < ActiveRecord::Migration[5.1]
  def up
    change_column :tags, :pc, :string, limit: 4
  end

  def down
    change column :tags, :pc, :string, limit: 2
  end
end
