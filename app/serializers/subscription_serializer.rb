class SubscriptionSerializer < BaseSerializer
  attributes :id,
             :name,
             :category,
             :amount,
             :is_variable_amount,
             :payment_method,
             :frequency,
             :next_billing_date,
             :status,
             :started_at,
             :ended_at,
             :total_spent,
             :last_used,
             :created_at,
             :updated_at

  belongs_to :user

  def frequency
    object.frequency_text
  end

  def category
    object.category_text
  end

  def status
    object.status_text
  end
end