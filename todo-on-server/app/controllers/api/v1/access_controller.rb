class Api::V1::AccessController < ApplicationController
  skip_before_action :authenticate

  def token
    user = User.find_by(email: params[:email])
    authenticated_user = user&.authenticate(params[:password])

    if authenticated_user
      token = Utils::JsonWebToken.encode(uid: user.id, jti: SecureRandom.uuid)
      expires_at = Utils::JsonWebToken.decode(token)[:exp]

      render json: { token:, expires_at: }, status: :ok
    else
      render json: { message: "Unauthorized" }, status: :unauthorized
    end
  end
end
