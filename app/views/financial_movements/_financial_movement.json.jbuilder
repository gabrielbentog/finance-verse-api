json.extract! financial_movement, :id, :user_id, :amount, :type, :category, :description, :date, :created_at, :updated_at
json.url financial_movement_url(financial_movement, format: :json)
