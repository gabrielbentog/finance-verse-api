class BaseSerializer < ActiveModel::Serializer
  # This class can be used to define common behavior for all serializers
  # in the application, such as custom methods or shared attributes.
  
  # Example of a shared method:
  def formatted_date(date)
    date.strftime("%B %d, %Y") if date.present?
  end

  # You can also define common attributes here if needed.
end
