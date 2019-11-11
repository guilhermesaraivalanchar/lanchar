require 'test_helper'

class DemandaEntradasControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get demanda_entradas_new_url
    assert_response :success
  end

end
