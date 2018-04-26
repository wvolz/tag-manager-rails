class Tag < ApplicationRecord
    has_many :tagscans
    def epc_dec
        if not epc.nil?
            epc.hex
        end
    end

    def last_tag_scan
        last = self.tagscans.order('created_at desc').first
        return last.created_at
    end
end
