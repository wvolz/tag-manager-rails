class Tag < ApplicationRecord
  has_many :tagscans, dependent: :destroy
  belongs_to :tag_type, optional: true
  has_and_belongs_to_many :authorizations, optional: true

  class PC < BinData::Record
    bit5 :len
    bit1 :user_memory
    bit1 :xpc
    bit1 :nsi
    bit8 :afi
  end

  def epc_dec
    epc&.hex
  end

  def last_tag_scan
    last = tagscans.order("created_at desc").first
    if last.present?
      last.created_at
    end
  end

  def pc_decode
    if @parsed_pc
      @parsed_pc
    elsif !pc.nil?
      indata_array = [ pc ].pack("H*").bytes
      indata = indata_array.pack("C*")
      @parsed_pc = PC.read(indata)
    end
  end

  def uii_decode
    if @parsed_uii
      @parsed_uii
    elsif !epc.nil?
      # TODO: do I need this?
      tag_type&.uii_decode(epc)
    end
  end
end
