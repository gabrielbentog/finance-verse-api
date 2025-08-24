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

  # Human readable labels (I18n aware)
  def category_text
    return nil unless category.present?
    I18n.t("subscriptions.category.#{category}", default: category.to_s.humanize)
  end

  def frequency_text
    return nil unless frequency.present?
    I18n.t("subscriptions.frequency.#{frequency}", default: frequency.to_s.humanize)
  end

  def status_text
    return nil unless status.present?
    I18n.t("subscriptions.status.#{status}", default: status.to_s.humanize)
  end
end
