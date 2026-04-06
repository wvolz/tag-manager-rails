class SettingsController < ApplicationController
  before_action :require_login

  def edit
    @retention_days  = Setting.image_retention_days
    @purge_enabled   = Setting.image_purge_enabled?
  end

  def update
    Setting.image_retention_days = params.dig(:settings, :image_retention_days).to_i.clamp(1, 36_500)
    Setting.image_purge_enabled  = params.dig(:settings, :image_purge_enabled) == "1"

    redirect_to edit_settings_path, notice: "Settings saved."
  end

  def purge_images
    PurgeTagscanImagesJob.perform_later(force: true)
    redirect_to edit_settings_path, notice: "Purge job enqueued. Images will be removed in the background."
  end
end
