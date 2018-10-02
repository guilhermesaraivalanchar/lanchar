require 'test_helper'

class CardapiosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get cardapios_index_url
    assert_response :success
  end

  test "should get edit" do
    get cardapios_edit_url
    assert_response :success
  end

  test "should get new" do
    get cardapios_new_url
    assert_response :success
  end

end
