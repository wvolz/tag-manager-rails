class CreateReaderAntennas < ActiveRecord::Migration[8.0]
  def change
    create_table :reader_antennas do |t|
      t.references :reader, null: false, foreign_key: true
      t.integer :antenna, null: false
      t.references :authorization, null: true, foreign_key: true

      t.timestamps
    end

    add_index :reader_antennas, [:reader_id, :antenna], unique: true
  end
end
