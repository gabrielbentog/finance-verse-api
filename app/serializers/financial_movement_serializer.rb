class FinancialMovementSerializer < BaseSerializer
  attributes :id, :amount, :type, :category, :description, :date, :user_id
end
