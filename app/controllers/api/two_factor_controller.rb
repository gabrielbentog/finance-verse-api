class Api::TwoFactorController < Api::ApiController
  before_action :authenticate_api_user!
  # NOTE: This controller tries to be defensive: it uses common helper
  # method names (provisioning_uri, generate_otp_secret!, verify_otp, etc.)
  # and falls back to ROTP/SecureRandom when needed.

  # Setup: ensure a secret exists and return provisioning URI + QR (svg + data URI)
  def setup
    # create secret if helper exists
    if current_api_user.respond_to?(:generate_otp_secret!)
      current_api_user.generate_otp_secret! if current_api_user.otp_secret.blank?
    elsif current_api_user.respond_to?(:otp_secret) && current_api_user.otp_secret.blank?
      # fallback: try to set a random secret (requires ROTP for TOTP generation)
      if defined?(ROTP)
        current_api_user.update(otp_secret: ROTP::Base32.random_base32) rescue nil
      end
    end

    # provisioning URI - prefer model helper, else compose via ROTP
    provisioning_uri = if current_api_user.respond_to?(:provisioning_uri)
                         current_api_user.provisioning_uri
                       elsif defined?(ROTP) && current_api_user.respond_to?(:otp_secret)
                         ROTP::TOTP.new(current_api_user.otp_secret, issuer: 'FinanceVerse').provisioning_uri(current_api_user.email)
                       end

    qr_svg = nil
    qr_svg_data_uri = nil
    if provisioning_uri.present?
      begin
        # generate SVG using rqrcode (gem 'rqrcode')
        qrcode = RQRCode::QRCode.new(provisioning_uri)
        qr_svg = qrcode.as_svg(
          offset: 0,
          color: '000',
          shape_rendering: 'crispEdges',
          module_size: 4
        )
        # also return a base64 data URI for easy <img> usage in the frontend
        qr_svg_data_uri = "data:image/svg+xml;base64,#{Base64.strict_encode64(qr_svg)}"
      rescue StandardError => e
        Rails.logger.warn("Failed to generate QR SVG: #{e.message}")
      end
    end

    render json: {
      issuer: 'FinanceVerse',
      account: current_api_user.email,
      secret: current_api_user.try(:otp_secret),
      provisioning_uri: provisioning_uri,
      qr_svg: qr_svg,
      qr_svg_data_uri: qr_svg_data_uri
    }, status: :ok
  end

  # Enable: confirm first TOTP code and activate 2FA. Returns backup codes once.
  def enable
    code = params.require(:code)
    if current_api_user.verify_otp(code)
      current_api_user.enable_two_factor!
      render json: { enabled: true, backup_codes: current_api_user.otp_backup_codes }, status: :ok
    else
      render json: { error: 'Invalid code' }, status: :unprocessable_entity
    end
  end

  # Regenerate backup codes (invalidate previous). Requires 2FA enabled.
  def regenerate_backup_codes
    two_factor_on = if current_api_user.respond_to?(:two_factor_enabled?)
                      current_api_user.two_factor_enabled?
                    else
                      current_api_user.try(:otp_required_for_login) == true
                    end

    return render json: { error: '2FA not enabled' }, status: :unprocessable_entity unless two_factor_on

    codes = if current_api_user.respond_to?(:generate_backup_codes)
              current_api_user.generate_backup_codes
            else
              Array.new(8) { SecureRandom.hex(4).upcase }
            end

    current_api_user.update!(otp_backup_codes: codes)
    render json: { backup_codes: codes }, status: :ok
  end

  # Disable 2FA
  def disable
    # opcional: exigir senha e/ou TOTP atual por segurança extra
    current_api_user.disable_two_factor!
    render json: { enabled: false }
  end
end