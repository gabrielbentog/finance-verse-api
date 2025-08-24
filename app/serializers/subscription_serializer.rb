class SubscriptionSerializer < BaseSerializer
  attributes :id,
             :name,
             :category,
             :amount,
             :is_variable_amount,
             :payment_method,
             :frequency,
             :billing_day,
             :next_billing_date,
             :status,
             :started_at,
             :ended_at,
             :total_spent,
             :last_used,
             :created_at,
             :updated_at

  belongs_to :user

  def next_billing_date
    return nil unless object.billing_day && object.started_at

    today = Date.today
    year = today.year
    month = today.month

    # Se o dia de pagamento já passou neste mês, calcula para o próximo mês
    if today.day > object.billing_day
      month += 1
      if month > 12
        month = 1
        year += 1
      end
    end

    begin
      next_date = Date.new(year, month, object.billing_day)
    rescue ArgumentError
      # Se o mês não tem esse dia (ex: 31 de fevereiro), pega o último dia do mês
      next_date = Date.new(year, month, -1)
    end

    next_date
  end

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