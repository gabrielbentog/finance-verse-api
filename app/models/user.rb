class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, 
  :recoverable, :rememberable, :validatable

  include DeviseTokenAuth::Concerns::User

  # Scopes

  # Associations
  has_one_attached :avatar
  has_many :movements, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validate :avatar_constraints

  # Callbacks
  # Uncomment to send confirmation email after user creation and add :confirmable module to Devise.
  # after_commit :send_confirmation_instructions, on: :create

  private

  def avatar_constraints
    return unless avatar.attached?
    errors.add(:avatar, "muito grande") if avatar.byte_size > 5.megabytes
    acceptable = ["image/jpeg", "image/png", "image/webp"]
    errors.add(:avatar, "tipo inválido") unless acceptable.include?(avatar.content_type)
  end
end
