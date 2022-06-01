class ConfirmationsController < ApplicationController
  def new
    @user = User.new
  end

  # create action will be used to resend confirmation instructions to an unconfirmed user.
  def create
    @user = User.find_by(email: params[:user][:email].downcase)

    if @user.present? && @user.unconfirmed?
      redirect_to root_path, notice: "Check your email for confirmation instructions."
    else
      redirect_to new_confirmation_path, alert: "We could not find a user with that email or that email has already been confirmed"
    end
  end

  # edit action is used to confirm a user's email. This page will be the page that the user lands on when they click the
  # confirmation link in their email.
  def edit
    @user = User.find_signed(params[:confirmation_token], purpose: :confirm_email)

    if @user.present?
      @user.confirm!
      redirect_to root path, notice: "Your account has been confirmed"
    else
      redirect_to new_confirmation_path, alert: "Invalid token."
    end
  end
end
