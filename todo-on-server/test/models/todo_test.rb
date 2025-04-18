require "test_helper"

class TodoTest < ActiveSupport::TestCase
  def setup
    @user = users(:one) # Assuming you have users fixtures
    @todo = Todo.new(title: "Complete Testing", content: "Testing for models, controller", status: false, user: @user)
  end

  test "todo should be valid with valid attributes" do
    assert @todo.valid?
  end

  test "todo should be invalid without a user" do
    @todo.user = nil
    assert_not @todo.valid?
    assert_equal [ "must exist" ], @todo.errors[:user]
  end

  test "todo should belong to a user" do
    association = Todo.reflect_on_association(:user)
    assert_equal :belongs_to, association.macro
    assert_equal "User", association.class_name
  end

  test "as_json should return only id, title, content, status and updated_at" do
    json_output = @todo.as_json
    assert_equal %w[ content id status title updated_at ].sort, json_output.keys.sort
    assert_equal @todo.id, json_output["id"]
    assert_equal @todo.title, json_output["title"]
    assert_equal @todo.content, json_output["content"]
    assert_equal @todo.status, json_output["status"]
    assert_equal @todo.updated_at, json_output["updated_at"]
    assert_nil json_output["created_at"]
  end
end
