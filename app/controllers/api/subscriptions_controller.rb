class Api::SubscriptionsController < Api::ApiController
  before_action :set_subscription, only: [:show, :update, :destroy]

  # GET /api/subscriptions
  def index
    subscriptions = current_api_user.subscriptions.apply_filters(params)

    render json: subscriptions, each_serializer: SubscriptionSerializer, meta: generate_meta(subscriptions), status: :ok
  end

  # GET /api/subscriptions/:id
  def show
    render json: @subscription, serializer: SubscriptionSerializer, status: :ok
  end

  # POST /api/subscriptions
  def create
    subscription = current_api_user.subscriptions.new(subscription_params)

    if subscription.save
      render json: subscription, serializer: SubscriptionSerializer, status: :created
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/subscriptions/:id
  def update
    if @subscription.update(subscription_params)
      render json: @subscription, serializer: SubscriptionSerializer, status: :ok
    else
      render json: { errors: @subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/subscriptions/:id
  def destroy
    @subscription.destroy
    head :no_content
  end

  # GET /api/subscriptions/analytics
  def analytics
    subscriptions = current_api_user.subscriptions
    active_subscriptions = subscriptions.where(status: 'active')
    total_monthly = active_subscriptions.sum(:amount)

    total_expenses = current_api_user.expenses.where("extract(month from date) = ?", Date.today.month).sum(:amount)
    percentage_of_expenses = total_expenses > 0 ? ((total_monthly / total_expenses) * 100).round(2) : 0

    render json: {
      data: {
        total_monthly_subscriptions: total_monthly,
        percentage_of_total_expenses: percentage_of_expenses,
        active_subscriptions_count: active_subscriptions.count
      }
    }, status: :ok
  end

  private

  def set_subscription
    @subscription = current_api_user.subscriptions.find(params[:id])
  end

  def subscription_params
    params.require(:subscription).permit(
      :name,
      :category,
      :amount,
      :is_variable_amount,
      :payment_method,
      :frequency,
      :billing_day,
      :status,
      :started_at,
      :ended_at,
      :total_spent,
      :last_used
    )
  end
end
