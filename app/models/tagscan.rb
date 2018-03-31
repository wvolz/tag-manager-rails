class Tagscan < ApplicationRecord
    def epc_dec
        if not epc.nil?
            epc.hex
        end
    end
end
