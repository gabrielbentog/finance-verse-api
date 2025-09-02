class Api::AuthenticationController < Api::ApiController
  skip_before_action :authenticate_api_user!, only: [:authenticate]

  def authenticate
    user = User.find_by(email: user_params[:email])

    if user&.valid_password?(user_params[:password])
      if user.two_factor_enabled?
        temp_token = user.signed_id(purpose: :two_factor, expires_in: 5.minutes)
        # Não entrega os headers de acesso ainda
        render json: { status: "2fa_required", temp_auth_token: temp_token, uid: user.uid, email: user.email }, status: :accepted
      else
        auth_token = user.create_new_auth_token
        response.headers.merge!(auth_token)
        render json: user, status: :ok
      end
    else
      render json: { error: I18n.t('devise.failure.invalid', authentication_keys: 'email') }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:authentication).permit(:email, :password)
  end
end
