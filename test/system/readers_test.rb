require "application_system_test_case"

class ReadersTest < ApplicationSystemTestCase
  setup do
    @reader = readers(:one)
  end

  test "visiting the index" do
    visit readers_url
    assert_selector "h1", text: "Readers"
  end

  test "should create reader" do
    visit readers_url
    click_on "New reader"

    fill_in "Location", with: @reader.location
    fill_in "Name", with: @reader.name
    click_on "Create Reader"

    assert_text "Reader was successfully created"
    click_on "Back"
  end

  test "should update Reader" do
    visit reader_url(@reader)
    click_on "Edit this reader", match: :first

    fill_in "Location", with: @reader.location
    fill_in "Name", with: @reader.name
    click_on "Update Reader"

    assert_text "Reader was successfully updated"
    click_on "Back"
  end

  test "should destroy Reader" do
    visit reader_url(@reader)
    click_on "Destroy this reader", match: :first

    assert_text "Reader was successfully destroyed"
  end
end
