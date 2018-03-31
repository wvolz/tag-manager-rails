class RemoveTagFieldsFromScan < ActiveRecord::Migration[5.1]
  def change
    remove_column :tagscans, :epc, :string
    remove_column :tagscans, :pc, :string
    add_reference :tagscans, :tag, foreign_key: true
  end
end
