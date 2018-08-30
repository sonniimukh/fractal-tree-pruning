require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest
  test "should get tree" do
    get api_tree_url
    assert_response :success
  end

end
