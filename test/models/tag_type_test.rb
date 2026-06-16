require "test_helper"

class TagTypeTest < ActiveSupport::TestCase
  test "resolves GS1-SGTIN company name from the local prefix map" do
    CompanyPrefixMap.create!(decoder: "GS1_SGTIN", company_prefix: 0x12345, company_name: "Acme Goods", active: true)
    tag_type = TagType.new(decoder: :GS1_SGTIN)

    epc = format("%096x", (0x30 << 88) | (0x1 << 85) | (0x3 << 82) |
      (0x12345 << 52) | (0x1234 << 38) | 0x123456789)

    decoded = tag_type.uii_decode(epc)

    assert_equal "Acme Goods", decoded.company_name
  end

  test "decodes GS1-SGTIN EPC metadata" do
    tag_type = TagType.new(decoder: :GS1_SGTIN)

    epc = format("%096x", (0x30 << 88) | (0x1 << 85) | (0x3 << 82) |
      (0x12345 << 52) | (0x1234 << 38) | 0x123456789)

    decoded = tag_type.uii_decode(epc)

    assert_equal 48, decoded.header
    assert_equal 1, decoded.filter
    assert_equal 3, decoded.partition
    assert_equal 0x12345, decoded.company_prefix
    assert_equal 0x1234, decoded.item_reference
    assert_equal 0x123456789, decoded.serial
  end
end
