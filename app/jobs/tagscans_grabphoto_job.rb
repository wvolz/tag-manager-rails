class TagscansGrabphotoJob < ApplicationJob
  queue_as :default

  def perform(tagscan)
    # Do something later
    tagscan.grabphoto
  end
end
