class MovementSerializer < BaseSerializer
  attributes :id, :title, :description, :amount, :movement_type, :category, :date, :created_at, :updated_at

  def date
    object.date.strftime("%Y-%m-%d") if object.date.present?
  end

  belongs_to :user
end
