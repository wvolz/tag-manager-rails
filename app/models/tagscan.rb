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
        self.tag = Tag.find_or_create_by(epc: epc) if epc.present?
    end

    def tag_pc=(pc)
        # this doesn't seem very efficient?
        self.tag = Tag.find_by(epc: self.tag_epc) if pc.present?
        self.tag.pc = pc
        self.tag.save
    end

    def grabphoto
        url = Rails.configuration.grabphoto_camera_url
        uri = URI.parse(url)
        uri.user = Rails.application.credentials.grab_photo[:username]
        uri.password = Rails.application.credentials.grab_photo[:password] 

        h = Net::HTTP.new uri.host, uri.port
 
        req = Net::HTTP::Get.new uri.request_uri

        res = h.request req

        digest_auth = Net::HTTP::DigestAuth.new
        auth = digest_auth.auth_header uri, res['www-authenticate'], 'GET'
 
        req = Net::HTTP::Get.new uri.request_uri
        req.add_field 'Authorization', auth

        res = h.request req

        # check request result here, if not 200 don't attach anything
        if res.is_a?(Net::HTTPSuccess)
          Tempfile.open('tagscan', :binmode => '1') do |f|
            f.write(res.body)
            # ensure file is written to disk
            f.flush
            # reset ios to beginning of file
            f.rewind
            current_date_time = DateTime.now.to_s(:number)
            self.image.attach(io: f,
                              filename: "#{current_date_time}-image.jpg",
                              content_type: 'image/jpg')
          end
        else
          # log issue grabbing image
          logger.info "Couldn't grab image from #{url} code #{res.code} msg #{res.msg}"
        end
    end
    
    def update_last_seen_time
        tag.last_seen_at = DateTime.current
        tag.save
    end
end
