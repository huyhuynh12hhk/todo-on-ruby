class Api::V1::TodosController < ApplicationController
  before_action :set_todo, only: %i[ show update_status destroy ]

  def create
    params[:todo][:status]=false
    @todo = @user.todos.create(todo_params)

    if @todo.save
      render json: { message: "Todo note was successfully created",  data: @todo.as_json() }
    else
      err = @todo.errors.full_messages
      # err = nil
      render json: { message: "Fail to create todo note", errors: err }, status: :bad_request
    end
  end

  def update_status
    if @todo.update(status: params[:status])
      render json: { message: "Todo note was successfully updated",  data: @todo.as_json() }
    else
      render json: { message: "Fail to update status of todo note", errors: err }, status: :bad_request
    end
  end

  def destroy
    @todo.destroy!
  end

  def index
    owner_id = params[:user_id]
    # binding.irb

    user = User.find(owner_id)
    todo = []
    if user
      todo = user.todos.map(&:as_json)
    end
    render json: { message: "Todo list", data: todo }
  end

  def show
    render json: { message: "Todo details", data: @todo.as_json }
  end

  private

  def set_todo
    @todo = Todo.find(params.expect(:id))
  end

  def todo_params
    params.expect(todo: [ :title, :content, :status ])
  end
end
