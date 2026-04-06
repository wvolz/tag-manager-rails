require "test_helper"

class SettingTest < ActiveSupport::TestCase
  test "image_retention_days returns 30 by default" do
    assert_equal 30, Setting.image_retention_days
  end

  test "image_retention_days returns stored value after assignment" do
    Setting.image_retention_days = 60
    assert_equal 60, Setting.image_retention_days
  end

  test "image_retention_days= is idempotent (upserts)" do
    Setting.image_retention_days = 45
    Setting.image_retention_days = 90
    assert_equal 90, Setting.image_retention_days
    assert_equal 1, Setting.where(key: Setting::IMAGE_RETENTION_DAYS_KEY).count
  end

  test "image_purge_enabled? returns false by default" do
    assert_not Setting.image_purge_enabled?
  end

  test "image_purge_enabled? returns true after enabling" do
    Setting.image_purge_enabled = true
    assert Setting.image_purge_enabled?
  end

  test "image_purge_enabled= can be toggled back to false" do
    Setting.image_purge_enabled = true
    Setting.image_purge_enabled = false
    assert_not Setting.image_purge_enabled?
  end
end
