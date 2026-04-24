class AddAuthorizerFieldsToReaders < ActiveRecord::Migration[8.0]
  def change
    add_reference :readers, :authorizer_app, foreign_key: true
    add_column :readers, :mac_address, :string
    add_column :readers, :reader_name, :string
    add_column :readers, :hostname, :string
    add_column :readers, :source_ip, :string
    add_column :readers, :last_seen_at, :datetime

    add_index :readers, :mac_address, unique: true
  end
end
