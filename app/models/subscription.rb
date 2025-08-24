class Subscription < ApplicationRecord
  # Enums
  enum :category, { service: 0, product: 1, membership: 2, other: 99 }
  enum :frequency, { monthly: 0, yearly: 1, weekly: 2, once: 3 }
  enum :status, { active: 0, paused: 1, cancelled: 2 }

  # Associations
  belongs_to :user

  # Scopes

  # Validations
  validates :name, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :frequency, inclusion: { in: frequencies.keys.map(&:to_s) }, allow_nil: true
  validates :status, inclusion: { in: statuses.keys.map(&:to_s) }, allow_nil: true
end
