class TagType < ApplicationRecord
  has_many :tags, dependent: :destroy

  enum :decoder, { None: 0, E470: 1 }

  class Classification < BinData::Record
    bit1 :vehicleClass
    bit5 :vehicleType
    bit4 :vehicleAxles
    bit1 :vehicleWeight
    bit1 :vehicleRearTires
  end

  class SIXCTOCUII < BinData::Record
    bit21 :agencyUse
    classification :classification
    bit3 :hovDeclaration
    bit4 :version
    bit12 :agency
    bit28 :transponderSerialNum
    bit16 :uiiValidationHash
  end

  def uii_decode(epc)
    if @parsed_uii
      @parsed_uii
    elsif decoder == "E470"
      unless epc.nil?
        indata_array = [ epc ].pack("H*").bytes
        indata = indata_array.pack("C*")
        @parsed_uii = SIXCTOCUII.read(indata)
      end
    end
  end
end
