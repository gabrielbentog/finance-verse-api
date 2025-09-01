class FinancialMovement < ApplicationRecord
  belongs_to :user
  # belongs_to :card, optional: true

  # Enums
  enum :movement_type, { income: 0, expense: 1 }

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :movement_type, presence: true

  # Scopes
  scope :by_period, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :by_type, ->(type) { where(movement_type: type) }
  # scope :by_card, ->(card_id) { where(card_id: card_id) }
end
