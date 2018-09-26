require 'test_helper'

class CombosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get combos_index_url
    assert_response :success
  end

  test "should get edit" do
    get combos_edit_url
    assert_response :success
  end

  test "should get new" do
    get combos_new_url
    assert_response :success
  end

end
