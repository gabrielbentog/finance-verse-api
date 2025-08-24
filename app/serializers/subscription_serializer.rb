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
end
