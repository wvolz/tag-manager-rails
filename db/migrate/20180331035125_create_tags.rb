class CreateTags < ActiveRecord::Migration[5.1]
  def change
    create_table :tags do |t|
      t.string :epc, limit: 24
      t.string :pc, limit: 2

      t.timestamps
    end
  end
end
