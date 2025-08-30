class Movement < ApplicationRecord
  enum :movement_type, { income: 0, expense: 1 }
  enum :activity_kind, { comercio: 0, transporte: 1, servicos: 2 }

  # Associations
  belongs_to :user

  # Scopes
  scope :by_movement_type, ->(type) { where(movement_type: type) }
  scope :business_related, -> { where(is_business: true) }
  scope :by_activity_kind, ->(kind) { where(activity_kind: kind) }
  
  # Ransackers para filtros de data
  ransacker :date_year do
    Arel.sql("EXTRACT(YEAR FROM date)")
  end

  ransacker :date_month do
    Arel.sql("EXTRACT(MONTH FROM date)")
  end

  ransacker :date_day do
    Arel.sql("EXTRACT(DAY FROM date)")
  end

  # Validations
  validates :title, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :movement_type, presence: true
  validates :date, presence: true
  validates :tax_exemption_percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :supporting_doc_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: 'deve ser uma URL válida' }, allow_blank: true

  # Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[title description amount movement_type category date is_business activity_kind tax_exemption_percentage created_at updated_at] + _ransackers.keys
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end

  # Métodos auxiliares
  def activity_kind_text
    return nil unless activity_kind.present?
    I18n.t("movements.activity_kind.#{activity_kind}", default: activity_kind.to_s.humanize)
  end

  def taxable_amount
    return amount unless is_business? && tax_exemption_percentage.present?
    amount * (1 - tax_exemption_percentage / 100.0)
  end

  def deductible_amount
    return 0 unless is_business? && expense?
    amount * (tax_exemption_percentage.present? ? tax_exemption_percentage / 100.0 : 1.0)
  end
end
