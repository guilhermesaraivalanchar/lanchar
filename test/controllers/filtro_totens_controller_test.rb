require 'test_helper'

class FiltroTotensControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get filtro_totens_index_url
    assert_response :success
  end

  test "should get new" do
    get filtro_totens_new_url
    assert_response :success
  end

  test "should get edit" do
    get filtro_totens_edit_url
    assert_response :success
  end

end
