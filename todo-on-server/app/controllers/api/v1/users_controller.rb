class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate, only: %i[ create show ]

  def create
    user = User.create(user_params)
    if user.save
      render json: { message: "User was successfully created",  data: user.as_json() }
    else
      # err = @user.errors.full_messages
      err = "Invalid Register Information"
      render json: { message: "Something went wrong when try to register", errors: err }, status: :bad_request
    end
  end

  def show
    user = User.find(params.expect(:id))
    render json: { message: "User details",  data: user.as_json() }
  end

  def index
    render json: { message: "User list", data: User.all.map(&:as_json) }
  end

  private

  def user_params
    params.permit(:email, :password, :full_name, :last_name)
  end
end
