require "test_helper"

class CompanyPrefixMapsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get company_prefix_maps_index_url
    assert_response :success
  end

  test "should get new" do
    get company_prefix_maps_new_url
    assert_response :success
  end

  test "should get create" do
    get company_prefix_maps_create_url
    assert_response :success
  end

  test "should get edit" do
    get company_prefix_maps_edit_url
    assert_response :success
  end

  test "should get update" do
    get company_prefix_maps_update_url
    assert_response :success
  end

  test "should get destroy" do
    get company_prefix_maps_destroy_url
    assert_response :success
  end
end
