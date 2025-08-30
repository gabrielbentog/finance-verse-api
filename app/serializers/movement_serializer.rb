class MovementSerializer < BaseSerializer
  attributes :id,
             :title,
             :description,
             :amount,
             :movement_type,
             :category,
             :date,
             :is_business,
             :activity_kind,
             :activity_kind_text,
             :tax_exemption_percentage,
             :supporting_doc_url,
             :taxable_amount,
             :deductible_amount,
             :created_at,
             :updated_at

  def date
    object.date.strftime("%Y-%m-%d") if object.date.present?
  end

  belongs_to :user
end
