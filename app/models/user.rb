class User < ApplicationRecord
  TOTP_INTERVAL = 30
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, 
  :recoverable, :rememberable, :validatable

  include DeviseTokenAuth::Concerns::User

  # Scopes

  # Associations
  has_one_attached :avatar
  has_many :movements, dependent: :destroy
  has_many :expenses, -> { where(movement_type: 'expense') }, class_name: 'Movement'
  has_many :subscriptions, dependent: :destroy

  # --- 2FA (TOTP) ---
  encrypts :otp_secret

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validate :avatar_constraints

  # Callbacks
  # Uncomment to send confirmation email after user creation and add :confirmable module to Devise.
  # after_commit :send_confirmation_instructions, on: :create

   def generate_otp_secret!
    update!(otp_secret: ROTP::Base32.random_base32)
  end

  def totp
    return nil if otp_secret.blank?
    # defina o issuer do seu app
    ROTP::TOTP.new(otp_secret, issuer: "SeuApp", interval: TOTP_INTERVAL)
  end

  def provisioning_uri(account_name = email)
    totp&.provisioning_uri(account_name)
  end

  def two_factor_enabled?
    otp_required_for_login && otp_secret.present?
  end

  def enable_two_factor!(codes: nil)
    update!(
      otp_required_for_login: true,
      otp_backup_codes: codes || generate_backup_codes
    )
  end

  def disable_two_factor!
    update!(otp_required_for_login: false, otp_secret: nil, otp_backup_codes: [])
  end

  # --- Verificações ---
  def verify_otp(code, drift: 1)
    return false if otp_secret.blank?

    # calcula o "passo" atual (janela de 30s)
    step_now  = Time.current.to_i / TOTP_INTERVAL
    last_step = otp_last_used_at ? (otp_last_used_at.to_i / TOTP_INTERVAL) : nil

    # evita reuso no mesmo time-step
    return false if last_step && last_step == step_now

    if totp.verify(code.to_s, drift_behind: drift, drift_ahead: drift)
      touch(:otp_last_used_at) # marca o uso bem sucedido
      true
    else
      false
    end
  end

  def generate_backup_codes(count: 10)
    Array.new(count) { SecureRandom.hex(4).upcase.scan(/.{4}/).join("-") }
  end

  def consume_backup_code!(code)
    codes = Array(otp_backup_codes)
    up    = code.to_s.upcase
    idx   = codes.index(up)
    return false unless idx

    codes.delete_at(idx)
    update!(otp_backup_codes: codes)
    true
  end

  private

  def avatar_constraints
    return unless avatar.attached?
    errors.add(:avatar, "muito grande") if avatar.byte_size > 5.megabytes
    acceptable = ["image/jpeg", "image/png", "image/webp"]
    errors.add(:avatar, "tipo inválido") unless acceptable.include?(avatar.content_type)
  end
end
