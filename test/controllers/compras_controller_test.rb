require 'test_helper'

class ComprasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get compras_index_url
    assert_response :success
  end

end
