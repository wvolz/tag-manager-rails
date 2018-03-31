class Tag < ApplicationRecord
    has_many :tagscans
    def epc_dec
        if not epc.nil?
            epc.hex
        end
    end
end
