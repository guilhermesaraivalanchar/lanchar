require 'test_helper'

class EquipamentosControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get equipamentos_show_url
    assert_response :success
  end

end
