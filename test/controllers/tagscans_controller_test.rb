require "test_helper"

class TagscansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tagscan = tagscans(:one)
  end

  test "should get index" do
    get tagscans_url

    assert_response :success
  end

  test "should get new" do
    get new_tagscan_url

    assert_response :success
  end

  test "should create tagscan" do
    assert_difference("Tagscan.count") do
      post tagscans_url,
        params: { tagscan: { antenna: @tagscan.antenna, pc: @tagscan.pc, rssi: @tagscan.rssi, epc: @tagscan.epc } }
    end

    assert_redirected_to tagscan_url(Tagscan.last)
  end

  test "should show tagscan" do
    get tagscan_url(@tagscan)

    assert_response :success
  end

  test "should get edit" do
    get edit_tagscan_url(@tagscan)

    assert_response :success
  end

  test "should update tagscan" do
    patch tagscan_url(@tagscan),
      params: { tagscan: { antenna: @tagscan.antenna, pc: @tagscan.pc, rssi: @tagscan.rssi, epc: @tagscan.epc } }

    assert_redirected_to tagscan_url(@tagscan)
  end

  test "should destroy tagscan" do
    assert_difference("Tagscan.count", -1) do
      delete tagscan_url(@tagscan)
    end

    assert_redirected_to tagscans_url
  end
end
