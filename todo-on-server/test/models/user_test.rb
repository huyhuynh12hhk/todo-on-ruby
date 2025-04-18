require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(email: "test@example.com", password: "password123", full_name: "Test User")
  end

  test "user should be valid with valid attributes" do
    assert @user.valid?
  end

  test "user should be invalid without an email" do
    @user.email = nil
    assert_equal @user.valid?, false
  end

  test "user should not have duplicate email" do
    existing_user = User.create(email: "test@example.com", password: "anotherpassword", full_name: "Existing User")
    assert_not @user.valid?
    assert_equal [ "has already been taken" ], @user.errors[:email]
  end

  test "user should have a secure password" do
    assert @user.respond_to?(:password)
    assert @user.respond_to?(:password_confirmation)
    assert_not_nil @user.password_digest
  end

  test "user should have many todos" do
    association = User.reflect_on_association(:todos)
    assert_equal :has_many, association.macro
    assert_equal "Todo", association.class_name
  end

  test "as_json should return only id, email, and full_name" do
    json_output = @user.as_json
    assert_equal %w[id email full_name].sort, json_output.keys.sort
    assert_equal @user.id, json_output["id"]
    assert_equal @user.email, json_output["email"]
    assert_equal @user.full_name, json_output["full_name"]
    assert_nil json_output["password_digest"]
    assert_nil json_output["image_url"]
    assert_nil json_output["created_at"]
    assert_nil json_output["updated_at"]
  end
end
