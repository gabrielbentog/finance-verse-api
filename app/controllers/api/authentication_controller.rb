class Api::AuthenticationController < Api::ApiController
  skip_before_action :authenticate_api_user!, only: [:authenticate]

  def authenticate
    user = User.find_by(email: user_params[:email])

    if user&.valid_password?(user_params[:password])
      auth_token = user.create_new_auth_token
      response.headers.merge!(auth_token)

      render json: user, serializer: UserSerializer
    else
      render json: { error: I18n.t('devise.failure.invalid', authentication_keys: 'email') }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:authentication).permit(:email, :password)
  end
end
