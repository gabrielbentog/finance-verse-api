class UserSerializer < BaseSerializer
  attributes :id, :name, :email, :avatar_url, :created_at, :updated_at

  def avatar_url
    if object.avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_url(object.avatar)
    else
      nil
    end
  end
end
