class Movement < ApplicationRecord

  enum :movement_type, { income: 0, expense: 1 }

  # Associations
  belongs_to :user
end
