class Subscription < ApplicationRecord
  # Enums
  enum :category, { service: 0, product: 1, membership: 2, other: 99 }
  # service: Serviço, product: Produto, membership: Inscrição, other: Outro

  enum :frequency, { monthly: 0, yearly: 1, weekly: 2, once: 3 }
  # monthly: Mensal, yearly: Anual, weekly: Semanal, once: Único  

  enum :status, { active: 0, paused: 1, cancelled: 2 }
  # active: Ativo, paused: Pausado, cancelled: Cancelado

  # Associations
  belongs_to :user

  # Scopes

  # Validations
  validates :name, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :frequency, inclusion: { in: frequencies.keys.map(&:to_s) }, allow_nil: true
  validates :status, inclusion: { in: statuses.keys.map(&:to_s) }, allow_nil: true

  # Callbacks
  after_create :set_started_at

  def set_started_at
    self.started_at ||= Time.current
    save
  end

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
