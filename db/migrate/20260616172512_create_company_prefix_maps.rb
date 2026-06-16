class CreateCompanyPrefixMaps < ActiveRecord::Migration[8.0]
  def change
    create_table :company_prefix_maps do |t|
      t.string :decoder
      t.integer :company_prefix
      t.string :company_name
      t.boolean :active
      t.text :notes

      t.timestamps
    end
  end
end
