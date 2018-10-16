require 'test_helper'

class EscolasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get escolas_index_url
    assert_response :success
  end

  test "should get show" do
    get escolas_show_url
    assert_response :success
  end

end
