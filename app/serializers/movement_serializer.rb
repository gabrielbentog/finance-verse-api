class MovementSerializer < BaseSerializer
  attributes :id, :title, :description, :amount, :movement_type, :category, :date, :created_at, :updated_at

  def date
    formatted_date(object.date)
  end

  belongs_to :user
end
