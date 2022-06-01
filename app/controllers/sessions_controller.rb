class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:user][:email].downcase)
    if @user
      if @user.unconfirmed?
        # We set the flash to "Incorrect email or password" if the user is unconfirmed to prevent
        # leaking email addresses.
        redirect_to new_confirmation_path, alert: "Incorrect email or password"
        # We're able to call user.authenticate because of `hassecurepassword`
      elsif @user.authenticate(params[:user][:password])
        login @user
        redirect_to root_path, notice: "Signed In."
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
    logout
    redirect_to root_path, notice: "Signed out."
  end
end
