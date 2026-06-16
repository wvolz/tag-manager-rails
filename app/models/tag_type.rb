class TagType < ApplicationRecord
  has_many :tags, dependent: :destroy

  enum :decoder, { None: 0, E470: 1, GS1_SGTIN: 2 }

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

  class GS1SGTIN96
    attr_reader :header, :filter, :partition, :company_prefix, :item_reference, :serial

    def initialize(header:, filter:, partition:, company_prefix:, item_reference:, serial:)
      @header = header
      @filter = filter
      @partition = partition
      @company_prefix = company_prefix
      @item_reference = item_reference
      @serial = serial
    end
  end

  def uii_decode(epc)
    return @parsed_uii if @parsed_uii

    if decoder == "E470" && epc.present?
      indata_array = [ epc ].pack("H*").bytes
      indata = indata_array.pack("C*")
      @parsed_uii = SIXCTOCUII.read(indata)
    elsif decoder == "GS1_SGTIN" && epc.present?
      @parsed_uii = decode_gs1_sgtin(epc)
    end

    @parsed_uii
  end

  private

  def decode_gs1_sgtin(epc)
    value = epc.to_s.hex
    bits = value.to_s(2).rjust(96, "0")

    header = bits[0, 8].to_i(2)
    filter = bits[8, 3].to_i(2)
    partition = bits[11, 3].to_i(2)

    company_prefix_bits, item_reference_bits = gs1_partition_layout(partition)
    company_prefix = bits[14, company_prefix_bits].to_i(2)
    item_reference = bits[14 + company_prefix_bits, item_reference_bits].to_i(2)
    serial = bits[58, 38].to_i(2)

    GS1SGTIN96.new(
      header: header,
      filter: filter,
      partition: partition,
      company_prefix: company_prefix,
      item_reference: item_reference,
      serial: serial
    )
  end

  def gs1_partition_layout(partition)
    {
      0 => [40, 4],
      1 => [37, 7],
      2 => [34, 10],
      3 => [30, 14],
      4 => [27, 17],
      5 => [24, 20],
      6 => [20, 24],
      7 => [17, 27]
    }.fetch(partition) { [40, 4] }
  end
end
