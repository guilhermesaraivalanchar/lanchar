require 'test_helper'

class TipoProdutosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tipo_produtos_index_url
    assert_response :success
  end

  test "should get edit" do
    get tipo_produtos_edit_url
    assert_response :success
  end

  test "should get new" do
    get tipo_produtos_new_url
    assert_response :success
  end

end
