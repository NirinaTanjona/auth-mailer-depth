class SessionsController < ApplicationController

  before_action :authenticate_user!, only: [:destroy]
  def new
  end

  def create
    @user = User.authenticate_by(email: params[:user][:email].downcase, password: params[:user][:password])
    if @user
      if @user.unconfirmed?
        # We set the flash to "Incorrect email or password" if the user is unconfirmed to prevent
        # leaking email addresses.
        redirect_to new_confirmation_path, alert: "Incorrect email or password"
        # We're able to call user.authenticate because of `hassecurepassword`
      elsif @user.authenticate(params[:user][:password])
        after_login_path = session[:user_return_to] || root_path
        active_session = login @user
        remember(active_session) if params[:user][:remember_me] == "1"
        redirect_to after_login_path, notice: "Signed In."
      else
        flash.now[:alert] = "Incorrect email or password"
        render :new, status: :unprocessable_entity
      end
    else
      flash.new[:alert] = "Incorrect email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    forget_active_session
    # forget(current_user)
    logout
    redirect_to root_path, notice: "Signed out."
  end
end
