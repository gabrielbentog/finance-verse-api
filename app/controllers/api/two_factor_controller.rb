class Api::TwoFactorController < Api::ApiController
  before_action :authenticate_api_user!

  # Gera segredo (se não existir) e retorna otpauth URI
  def setup
    current_api_user.generate_otp_secret! if current_api_user.otp_secret.blank?
    render json: {
      issuer: "SeuApp",
      account: current_api_user.email,
      secret: current_api_user.otp_secret,
      provisioning_uri: current_api_user.provisioning_uri
    }
  end

  # Confirma com o primeiro código e ativa (retorna backup codes uma vez)
  def enable
    code = params.require(:code)
    if current_api_user.verify_otp(code)
      current_api_user.enable_two_factor!
      render json: { enabled: true, backup_codes: current_api_user.otp_backup_codes }, status: :ok
    else
      render json: { error: "Invalid code" }, status: :unprocessable_entity
    end
  end

  # Regenera backup codes (invalida anteriores)
  def regenerate_backup_codes
    return render json: { error: "2FA not enabled" }, status: :unprocessable_entity unless current_api_user.two_factor_enabled?

    codes = current_api_user.generate_backup_codes
    current_api_user.update!(otp_backup_codes: codes)
    render json: { backup_codes: codes }
  end

  # Desativa 2FA
  def disable
    # opcional: exigir senha e/ou TOTP atual por segurança extra
    current_api_user.disable_two_factor!
    render json: { enabled: false }
  end
end