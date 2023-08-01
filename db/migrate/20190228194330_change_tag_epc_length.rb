class ChangeTagEpcLength < ActiveRecord::Migration[5.1]
  def up
    change_column :tags, :epc, :string, limit: 124
  end

  def down
    change column :tags, :epc, :string, limit: 24
  end
end
