class User < ApplicationRecord
  CONFIRMATION_TOKEN_EXPIRATION = 10.minutes
  PASSWORD_RESET_TOKEN_EXPIRATION = 10.minutes

  MAILER_FROM_EMAIL = "no-reply@exemple.com"

  has_many :active_sessions, dependent: :destroy

  attr_accessor :current_password

  # has_secure_password method is added to give us an API to work with the "password_digest"
  has_secure_password
  # This ensures that the value for this column will be set when the record is created. This value
  # will be used later to securely identify the user.
  # has_secure_token :remember_token
  # we save all emails to the database in downcase format via a before_save callback such that
  # the values are saved in consistant format
  before_save :downcase_email
  before_save :downcase_unconfirmed_email

  #we use URI::MailTo::EMAIL_REGEXP that comes with Ruby to validate the format of the email
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, presence: true, uniqueness: true
  validates :unconfirmed_email, format: {with: URI::MailTo::EMAIL_REGEXP}, allow_blank: true

  # The confirm method will be called when a user confirms their email address.
  def confirm!
    if unconfirmed_or_reconfirming?
      if unconfirmed_email.present?
        return false unless update(email: unconfirmed_email, unconfirmed_email: nil)
      end
      update_columns(confirmed_at: Time.current)
    else
      false
    end
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

  def confirmable_email
    if unconfirmed_email.present?
      unconfirmed_email
    else
      email
    end
  end

  def reconfirming?
    unconfirmed_email.present?
  end

  def unconfirmed_or_reconfirming?
    unconfirmed? || reconfirming?
  end

  # [["email", "john doe"], ["password", "1234"]].to_h => {"email" => "john doe", "password" => "1234" }
  # Array.to_h.partition => enumeration with key value
  # map(&:to_h) => change the returned value to hashmap, "&" avoid an "error" for nil in the returned value
  def self.authenticate_by(attributes)
    passwords, identifiers = attributes.to_h.partition do |name, value|
      !has_attribute?(name) && has_attribute?("#{name}_digest")
    end.map(&:to_h)

    raise ArgumentError, "One or more password arguments are required" if passwords.empty?
    raise ArgumentError, "One or more finder arguments are required" if identifiers.empty?
    if (record = find_by(identifiers))
      record if passwords.count { |name, value| record.public_send(:"authenticate_#{name}", value) } == passwords.size
    else
      new(passwords)
      nil
    end
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def downcase_unconfirmed_email
    return if unconfirmed_email.nil?
    self.unconfirmed_email = unconfirmed_email.downcase
  end

end
