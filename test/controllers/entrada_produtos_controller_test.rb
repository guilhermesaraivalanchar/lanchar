require 'test_helper'

class EntradaProdutosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get entrada_produtos_index_url
    assert_response :success
  end

end
