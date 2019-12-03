class Tagscan < ApplicationRecord
    belongs_to :tag
    has_one_attached :image

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
       
        Tempfile.open('tagscan', :binmode => '1') do |f|
          f.write(res.body)
          # ensure file is written to disk
          f.flush
          # reset ios to beginning of file
          f.rewind
          self.image.attach(io: f,
                            filename: 'image.jpg',
                            content_type: 'image/jpg')
        end
    end
end
