class Tagscan < ApplicationRecord
  belongs_to :tag
  has_one_attached :image
  after_create :update_last_seen_time
  scope :by_created, -> { order(created_at: :desc) }

  def tag_epc
    tag.try(:epc)
  end

  def tag_pc
    tag.try(:pc)
  end

  def tag_epc=(epc)
    self.tag = Tag.find_or_create_by(epc:) if epc.present?
  end

  # rubocop:disable Naming/MethodParameterName
  def tag_pc=(pc)
    # this doesn't seem very efficient?
    self.tag = Tag.find_by(epc: tag_epc) if pc.present?
    tag.pc = pc
    tag.save
  end
  # rubocop:enable Naming/MethodParameterName

  def grabphoto
    url = Rails.configuration.grabphoto_camera_url
    username = Rails.application.credentials.grab_photo[:username]
    password = Rails.application.credentials.grab_photo[:password]

    request = Typhoeus::Request.new(
      url,
      username:,
      password:,
      httpauth: :digest
    )

    # check request result here, if not 200 don't attach anything
    request.on_complete do |response|
      if response.success?
        attach_tagscan_image(response.body)
      elsif response.timed_out?
        logger.info "Timeout grabbing image from #{url}"
      elsif response.code == 0
        # Could not get an http response, something's wrong.
        logger.info(response.return_message)
      else
        logger.info "Couldn't grab image from #{url} code #{response.code}"
      end
    end

    request.run
  end

  def update_last_seen_time
    tag.last_seen_at = DateTime.current
    tag.save
  end

  private

  def attach_tagscan_image(input_file)
    Tempfile.open("tagscan", binmode: "1") do |f|
      f.write(input_file)
      # ensure file is written to disk
      f.flush
      # reset IOS to beginning of file
      f.rewind
      current_date_time = DateTime.now.to_fs(:number)
      image.attach(
        io: f,
        filename: "#{current_date_time}-image.jpg",
        content_type: "image/jpeg"
      )
    end
  end
end
