require 'test_helper'

class TipoUsersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tipo_users_index_url
    assert_response :success
  end

  test "should get new" do
    get tipo_users_new_url
    assert_response :success
  end

  test "should get edit" do
    get tipo_users_edit_url
    assert_response :success
  end

end
