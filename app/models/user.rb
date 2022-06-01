class User < ApplicationRecord
  CONFIRMATION_TOKEN_EXPIRATION = 10.minutes
  PASSWORD_RESET_TOKEN_EXPIRATION = 10.minutes

  MAILER_FROM_EMAIL = "no-reply@exemple.com"

  # has_secure_password method is added to give us an API to work with the "password_digest"
  has_secure_password
  # we save all emails to the database in downcase format via a before_save callback such that
  # the values are saved in consistant format
  before_save :downcase_email

  #we use URI::MailTo::EMAIL_REGEXP that comes with Ruby to validate the format of the email
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, presence: true, uniqueness: true

  # The confirm method will be called when a user confirms their email address. We still need to
  # build this feature
  def confirm!
    update_columns(confirmed_at: Time.current)
  end

  def confirmed?
    confirmed_at.present?
  end

  def unconfirmed?
    !confirmed?
  end

  # The generate_confirmation_token method creates a signed_id that will be used to securely identify
  # the user. For added security, we ensure that this ID will expire in 10 minutes
  # (this can be controlled with the CONFIRMATION_TOKEN_EXPIRATION constant) and give it an
  # explicit purpose of :confirm_email. This will be useful when we build the confirmation mailer.
  def generate_confirmation_token
    signed_id expires_in: CONFIRMATION_TOKEN_EXPIRATION, purpose: :confirm_email
  end

  def generate_password_reset_token
    signed_id expires_in: PASSWORD_RESET_TOKEN_EXPIRATION, purpose: :reset_password
  end

  def send_confirmation_email!
    confirmation_token = generate_confirmation_token
    UserMailer.confirmation(self, confirmation_token).deliver_now
  end

  def send_password_reset_email!
    password_reset_token = generate_password_reset_token
    UserMailer.password_reset(self, password_reset_token).deliver_now
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
