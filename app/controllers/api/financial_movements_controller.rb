class Api::FinancialMovementsController < Api::ApiController
  before_action :set_financial_movement, only: [:show, :update, :destroy]

  def index
    financial_movements = current_api_user.financial_movements.apply_filters(params)
    render json: financial_movements, 
           each_serializer: FinancialMovementSerializer, 
           meta: generate_meta(financial_movements), 
           status: :ok
  end

  def show
    render json: @financial_movement, serializer: FinancialMovementSerializer
  end

  def create
    financial_movement = current_api_user.financial_movements.new(financial_movement_params)

    if financial_movement.save
      render json: financial_movement, 
             serializer: FinancialMovementSerializer, 
             status: :created
    else
      render json: { errors: financial_movement.errors.full_messages }, 
             status: :unprocessable_entity
    end
  end

  def update
    if @financial_movement.update(financial_movement_params)
      render json: @financial_movement, serializer: FinancialMovementSerializer
    else
      render json: { errors: @financial_movement.errors.full_messages }, 
             status: :unprocessable_entity
    end
  end

  def destroy
    @financial_movement.destroy
    head :no_content
  end

  private

  def set_financial_movement
    @financial_movement = current_api_user.financial_movements.find(params[:id])
  end

  def financial_movement_params
    params.require(:financial_movement).permit(
      :amount, 
      :movement_type, 
      :category_id,
      :description, 
      :date
    )
  end
end
