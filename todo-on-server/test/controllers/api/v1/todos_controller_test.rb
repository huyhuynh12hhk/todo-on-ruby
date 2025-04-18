require "test_helper"

class Api::V1::TodosControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  def setup
    @user = users(:one)
    @todo = todos(:one)
    @valid_token = Utils::JsonWebToken.encode(uid: @user.id)
  end

  def auth_headers
    { "Authorization": "Bearer #{@valid_token}" }
  end

  test "should create a todo with valid attributes" do
    assert_difference("Todo.count") do
      post "/api/v1/users/#{@user.id}/todos", params: { todo: { title: "New Todo", content: "Test todo" } }, headers: auth_headers
    end
    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Todo note was successfully created", json_response["message"]
    assert_equal "New Todo", json_response["data"]["title"]
    assert_equal false, json_response["data"]["status"]
  end

  test "should not create a todo with invalid attributes" do
    assert_no_difference("Todo.count") do
      post "/api/v1/users/#{@user.id}/todos", params: { todo: { title: nil, content: nil } }, headers: auth_headers
    end
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Fail to create todo note", json_response["message"]
  end

  test "should update todo status" do
    patch "/api/v1/users/#{@user.id}/todos/#{@todo.id}/update-status", params: { status: true }, headers: auth_headers
    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Todo note was successfully updated", json_response["message"]
    assert_equal true, json_response["data"]["status"]
    @todo.reload
    assert_equal true, @todo.status
  end

  test "should destroy a todo" do
    assert_difference("Todo.count", -1) do
      delete "/api/v1/users/#{@user.id}/todos/#{@todo.id}", headers: auth_headers
    end
    assert_response :no_content
    assert_raises(ActiveRecord::RecordNotFound) { Todo.find(@todo.id) }
  end

  test "should show a specific todo" do
    get "/api/v1/users/#{@user.id}/todos/#{@todo.id}", headers: auth_headers
    assert_response :ok
    json_response = JSON.parse(response.body)
    assert_equal "Todo details", json_response["message"]
    assert_equal @todo.id, json_response["data"]["id"]
  end

  test "should not show a non-existent todo" do
    get "/api/v1/users/#{@user.id}/todos/#{@todo.id}/100", headers: auth_headers
    assert_response :not_found
  end

  test "should require authentication for all actions except index and show (adjust as needed)" do
    # Test create without token
    post "/api/v1/users/#{@user.id}/todos", params: { todo: { name: nil, completed: false, user_id: @user.id } }
    assert_response :unauthorized

    # Test update_status without token
    patch "/api/v1/users/#{@user.id}/todos/#{@todo.id}/update-status", params: { status: true }
    assert_response :unauthorized

    # Test destroy without token
    delete "/api/v1/users/#{@user.id}/todos/#{@todo.id}"
    assert_response :unauthorized

    # Test show without token
    get "/api/v1/users/#{@user.id}/todos/#{@todo.id}"
    assert_response :unauthorized
  end
end
