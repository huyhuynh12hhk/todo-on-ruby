require "test_helper"

class Api::V1::AccessControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one) # Assuming you have users fixtures
  end

  test "should return a token with valid credentials" do
    post "/api/v1/auth/token", params: { email: @user.email, password: "secret" }
    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_not_nil json_response["token"]
    assert_not_nil json_response["expires_at"]
  end

  test "should return unauthorized with invalid email" do
    post "/api/v1/auth/token", params: { email: "wrong@example.com", password: "secret" }
    assert_response :unauthorized
    assert_equal "Unauthorized", JSON.parse(response.body)["message"]
  end

  test "should return unauthorized with invalid password" do
    post "/api/v1/auth/token", params: { email: @user.email, password: "wrongpassword" }
    assert_response :unauthorized
    assert_equal "Unauthorized", JSON.parse(response.body)["message"]
  end

  test "should return unauthorized with missing email" do
    post "/api/v1/auth/token", params: { password: "secret" }
    assert_response :unauthorized
    assert_equal "Unauthorized", JSON.parse(response.body)["message"]
  end

  test "should return unauthorized with missing password" do
    post "/api/v1/auth/token", params: { email: @user.email }
    assert_response :unauthorized
    assert_equal "Unauthorized", JSON.parse(response.body)["message"]
  end
end
