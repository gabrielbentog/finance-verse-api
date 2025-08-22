class Api::MovementsController < Api::ApiController
  before_action :set_movement, only: [:show, :update, :destroy]

  def index
    movements = current_api_user.movements.apply_filters(params)
    render json: movements, each_serializer: MovementSerializer, meta: generate_meta(movements), status: :ok
  end

  def show
    render json: @movement, serializer: MovementSerializer
  end

  def create
    movement = current_api_user.movements.new(movement_params)

    if movement.save
      render json: movement, serializer: MovementSerializer, status: :created
    else
      render json: { errors: movement.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @movement.update(movement_params)
      render json: @movement, serializer: MovementSerializer
    else
      render json: { errors: @movement.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @movement.destroy
    head :no_content
  end

  private

  def set_movement
    @movement = current_api_user.movements.find(params[:id])
  end

  def movement_params
    params.require(:movement).permit(:title, :description, :amount, :movement_type, :category, :date)
  end
end
