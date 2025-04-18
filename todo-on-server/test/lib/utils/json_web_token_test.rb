require "test_helper"
require "utils/json_web_token"

class Utils::JsonWebTokenTest < ActiveSupport::TestCase
  def setup
    @payload = { uid: 123, some_data: "test" }
    @token = Utils::JsonWebToken.encode(@payload)
  end

  test "encode should return a valid JWT string" do
    assert_kind_of String, @token
    decoded_token = JWT.decode(@token, Rails.application.secret_key_base, true)
    assert_equal @payload[:uid], decoded_token[0]["uid"]
    assert_equal @payload[:some_data], decoded_token[0]["some_data"]
    assert_kind_of Integer, decoded_token[0]["iat"]
    assert_kind_of Integer, decoded_token[0]["exp"]
  end

  test "decode should return a HashWithIndifferentAccess payload" do
    decoded_payload = Utils::JsonWebToken.decode(@token)
    assert_kind_of HashWithIndifferentAccess, decoded_payload
    assert_equal @payload[:uid], decoded_payload[:uid]
    assert_equal @payload[:some_data], decoded_payload[:some_data]
  end

  test "decode should handle expired tokens" do
    expired_payload = { uid: 456 }
    expired_token = Utils::JsonWebToken.encode(expired_payload, 1.second.ago)

    assert_raises JWT::ExpiredSignature do
      Utils::JsonWebToken.decode(expired_token)
    end
  end

  test "decode should handle invalid tokens (e.g., tampered)" do
    invalid_token_parts = @token.split(".")
    tampered_payload = Base64.urlsafe_encode64("{\"uid\": 789}")
    invalid_token = "#{invalid_token_parts[0]}.#{tampered_payload}.#{invalid_token_parts[2]}"

    assert_raises JWT::DecodeError do
      Utils::JsonWebToken.decode(invalid_token)
    end
  end
end
