class Api::ApiController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include LoggableRequest

  before_action :underscore_params
  before_action :authenticate_api_user!
  after_action :camelize_response

  private

  def underscore_params
    params.deep_transform_keys!(&:underscore)
  end

  def generate_meta(collection, extra: {})
    {
      pagination: {
        total_count:  collection.total_count,
        total_pages:  collection.total_pages,
        current_page: collection.current_page,
        per_page:     collection.limit_value
      }
    }.merge(extra.symbolize_keys)
  end

  def camelize_response
    return unless response.media_type == 'application/json'

    body = response.body.presence && JSON.parse(response.body) rescue nil
    return unless body

    camelized = body.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    response.body = camelized.to_json
  end
end
