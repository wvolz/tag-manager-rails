class CreateTagscans < ActiveRecord::Migration[5.1]
  def change
    create_table :tagscans do |t|
      t.string :epc, limit: 24
      t.integer :pc, limit: 2
      t.integer :antenna
      t.integer :rssi

      t.timestamps
    end
  end
end
