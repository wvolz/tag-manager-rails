class MigrateReaderApiKeysToAuthorizerApp < ActiveRecord::Migration[8.0]
  def up
    authorizer_app_id = ensure_authorizer_app

    execute <<~SQL.squish
      UPDATE readers
      SET authorizer_app_id = #{authorizer_app_id}
      WHERE authorizer_app_id IS NULL
    SQL

    execute <<~SQL.squish
      UPDATE api_keys
      SET bearer_type = 'AuthorizerApp', bearer_id = #{authorizer_app_id}
      WHERE bearer_type = 'Reader'
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot safely map AuthorizerApp API keys back to Reader bearers"
  end

  private

  def ensure_authorizer_app
    existing_id = select_value("SELECT id FROM authorizer_apps ORDER BY id ASC LIMIT 1")
    return existing_id if existing_id.present?

    execute <<~SQL.squish
      INSERT INTO authorizer_apps (name, description, created_at, updated_at)
      VALUES ('Primary Authorizer', 'Default authorizer app', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    SQL

    select_value("SELECT id FROM authorizer_apps ORDER BY id ASC LIMIT 1")
  end
end
