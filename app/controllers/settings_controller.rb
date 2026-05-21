class SettingsController < ApplicationController
  before_action :require_login

  def edit
    @retention_days  = Setting.image_retention_days
    @purge_enabled   = Setting.image_purge_enabled?
    @classification_enabled = Setting.image_classification_enabled?
    @classification_endpoint = Setting.image_classification_endpoint
    @classification_min_confidence = Setting.image_classification_min_confidence
    @purge_without_relevant_detections_enabled = Setting.image_purge_without_relevant_detections_enabled?
    @purge_without_relevant_detections_min_confidence = Setting.image_purge_without_relevant_detections_min_confidence
  end

  def update
    Setting.image_retention_days = params.dig(:settings, :image_retention_days).to_i.clamp(1, 36_500)
    Setting.image_purge_enabled  = params.dig(:settings, :image_purge_enabled) == "1"
    Setting.image_classification_enabled = params.dig(:settings, :image_classification_enabled) == "1"
    Setting.image_classification_endpoint = params.dig(:settings, :image_classification_endpoint)
    Setting.image_classification_min_confidence = params.dig(:settings, :image_classification_min_confidence)
    Setting.image_purge_without_relevant_detections_enabled = params.dig(:settings, :image_purge_without_relevant_detections_enabled) == "1"
    Setting.image_purge_without_relevant_detections_min_confidence = params.dig(:settings, :image_purge_without_relevant_detections_min_confidence)

    redirect_to edit_settings_path, notice: "Settings saved."
  end

  def purge_images
    PurgeTagscanImagesJob.perform_later(force: true)
    redirect_to edit_settings_path, notice: "Purge job enqueued. Images will be removed in the background."
  end

  def classify_unclassified_images
    BackfillTagscanImageClassificationsJob.perform_later(force: false)
    redirect_to edit_settings_path, notice: "Classification backfill enqueued for unclassified images."
  end

  def reclassify_images
    BackfillTagscanImageClassificationsJob.perform_later(force: true)
    redirect_to edit_settings_path, notice: "Reclassification enqueued for all images with attachments."
  end
end
