class AddImageClassificationToTagscans < ActiveRecord::Migration[8.0]
  def change
    add_column :tagscans, :image_classification_status, :string
    add_column :tagscans, :image_classified_at, :datetime
    add_column :tagscans, :image_classification_error, :text
    add_column :tagscans, :image_classification_payload, :text
    add_column :tagscans, :contains_person, :boolean, null: false, default: false
    add_column :tagscans, :contains_vehicle, :boolean, null: false, default: false
    add_column :tagscans, :contains_animal, :boolean, null: false, default: false
    add_column :tagscans, :person_confidence, :decimal, precision: 5, scale: 4
    add_column :tagscans, :vehicle_confidence, :decimal, precision: 5, scale: 4
    add_column :tagscans, :animal_confidence, :decimal, precision: 5, scale: 4

    add_index :tagscans, :image_classification_status
    add_index :tagscans, :contains_person
    add_index :tagscans, :contains_vehicle
    add_index :tagscans, :contains_animal
  end
end