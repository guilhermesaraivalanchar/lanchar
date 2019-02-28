require 'test_helper'

class TipoCreditosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tipo_creditos_index_url
    assert_response :success
  end

  test "should get new" do
    get tipo_creditos_new_url
    assert_response :success
  end

  test "should get edit" do
    get tipo_creditos_edit_url
    assert_response :success
  end

end
