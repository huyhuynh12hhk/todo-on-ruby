require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @valid_token = Utils::JsonWebToken.encode(uid: @user.id)
  end

  def auth_headers
    { "Authorization": "Bearer #{@valid_token}" }
  end

  test "should create a user with valid attributes" do
    assert_difference("User.count") do
      post "/api/v1/users/register", params: { email: "newuser@example.com", password: "password123", full_name: "New User" }
    end
    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "User was successfully created", json_response["message"]
    assert_equal "newuser@example.com", json_response["data"]["email"]
    assert_equal "New User", json_response["data"]["full_name"]
  end

  test "should not create a user with invalid attributes" do
    assert_no_difference("User.count") do
      post "/api/v1/users/register", params: { email: nil, password: "password123", full_name: "New User" }
    end
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Something went wrong when try to register", json_response["message"]
    assert_equal "Invalid Register Information", json_response["errors"]
  end

  test "should show a specific user" do
    get "/api/v1/users/#{@user.id}", headers: auth_headers
    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "User details", json_response["message"]
    assert_equal @user.id, json_response["data"]["id"]
    assert_equal @user.email, json_response["data"]["email"]
    assert_equal @user.full_name, json_response["data"]["full_name"]
  end

  test "should not show a non-existent user" do
    get "/api/v1/users/999"
    assert_response :not_found
  end

  test "should get index of all users" do
    get "/api/v1/users", headers: auth_headers
    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "User list", json_response["message"]
    assert_equal User.count, json_response["data"].count
  end

  test "should allow unauthenticated access to create and show actions" do
    # Create action
    post "/api/v1/users/register", params: { email: "test_unauth@example.com", password: "password", full_name: "Test Unauth" }
    assert_response :ok

    # Show action
    get "/api/v1/users/#{@user.id}"
    assert_response :ok

    # Index action
    get "/api/v1/users", headers: { "Authorization": "Bearer invalid_token" }
    assert_response :unauthorized
  end
end
