class Movement < ApplicationRecord
  include Filterable

  enum :movement_type, { income: 0, expense: 1 }

  # Associations
  belongs_to :user

  # Scopes
  scope :by_movement_type, ->(type) { where(movement_type: type) }
  
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
  # Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[title description amount movement_type category date created_at updated_at] + _ransackers.keys
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user]
  end
end
