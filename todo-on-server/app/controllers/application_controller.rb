class ApplicationController < ActionController::API
  before_action :authenticate

  rescue_from JWT::VerificationError, with: :invalid_token
  rescue_from JWT::DecodeError, with: :invalid_token

  private

  def authenticate
    authorization_header =request.headers["Authorization"]
    token = authorization_header.split(" ").last if authorization_header
    decode_token = Utils::JsonWebToken.decode(token)

    @user = User.find(decode_token[:uid])
  end

  def invalid_token
    render json: { message: "Invalid token" }, status: :unauthorized
  end

  def decode_error
    render json: { message: "Decode error" },  status: :bad_request
  end
end
