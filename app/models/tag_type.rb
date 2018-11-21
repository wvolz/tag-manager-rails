class TagType < ApplicationRecord
    has_many :tags

    enum decoder: [:None, :E470]

    class Classification < BinData::Record
      bit1  :vehicleClass
      bit5  :vehicleType
      bit4  :vehicleAxles
      bit1  :vehicleWeight
      bit1  :vehicleRearTires
    end

    class SIXCTOCUII < BinData::Record
      bit21  :agencyUse
      classification  :classification
      bit3   :hovDeclaration
      bit4   :version
      bit12  :agency
      bit28  :transponderSerialNum
      bit16  :uiiValidationHash
    end

    def uii_decode(epc)
        if @parsed_uii
            return @parsed_uii
        else
            if decoder == 'E470'
                if not epc.nil?
                    indata_array = [epc].pack('H*').bytes
                    indata = indata_array.pack('C*')
                    @parsed_uii = SIXCTOCUII.read(indata)
                end
            end
        end 
    end
end
