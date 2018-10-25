require 'test_helper'

class FornecedoresControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get fornecedores_index_url
    assert_response :success
  end

  test "should get new" do
    get fornecedores_new_url
    assert_response :success
  end

  test "should get edit" do
    get fornecedores_edit_url
    assert_response :success
  end

end
