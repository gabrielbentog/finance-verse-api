class Api::TwoFactorVerificationController < Api::ApiController
  skip_before_action :authenticate_api_user!

  def create
    user = User.find_signed!(params.require(:temp_auth_token), purpose: :two_factor)

    code = params.require(:code).to_s.strip.upcase
    if user.verify_otp(code) == true || user.consume_backup_code!(code)
      token_headers = user.create_new_auth_token
      response.headers.merge!(token_headers)
      render json: user, serializer: UserSerializer
   else
      render json: { error: "Invalid code" }, status: :unauthorized
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render json: { error: "Token expired or invalid" }, status: :unauthorized
  end
end