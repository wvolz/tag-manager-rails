class Tag < ApplicationRecord
    has_many :tagscans
    belongs_to :tag_type, optional: true
    has_and_belongs_to_many :authorizations, optional: true

    class PC < BinData::Record
      bit5  :len
      bit1  :user_memory
      bit1  :xpc
      bit1  :nsi
      bit8  :afi
    end

    def epc_dec
        if not epc.nil?
            epc.hex
        end
    end

    def last_tag_scan
        last = self.tagscans.order('created_at desc').first
        if last.present?
            return last.created_at
        else
            return
        end
    end

    def pc_decode
        if @parsed_pc
            return @parsed_pc
        else
            if not pc.nil?
                indata_array = [pc].pack('H*').bytes
                indata = indata_array.pack('C*')
                @parsed_pc = PC.read(indata)
            end
        end 
    end

    def uii_decode
        if @parsed_uii
            return @parsed_uii
        else
            # TODO do I need this?
            if not epc.nil?
                if not tag_type.nil?
                    tag_type.uii_decode(epc)
                end
            end
        end
    end
end
