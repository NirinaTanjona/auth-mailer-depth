module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :current_user
    helper_method :current_user
    helper_method :user_signed_in
  end

  # We set the user's ID in the session so that we can have access to the user across requests.
  # The user's ID won't be stored in plain text. The cookie data is cryptographically signed to make
  # it tamper-proof. And it is also encrypted so anyone with access to it can't read its contents.
  def login(user)
    reset_session
    session[:current_user_id] = user.id
  end

  def logout
    reset_session
  end

  def redirect_if_authenticated
    redirect_to root_path, alert: "You are already logged in." if user_signed_in?
  end

  private

  # The current_user methods returns a User and sets it as the user on the Current class we created
  # We use `memoization` to avoid fetching the User each time on the Current class we created
  # We call before_action filter so that we have access to the current user before each request.
  # We also add this as `helper_method` so that we have access to `current_user` in the view.
  def current_user
    Current.user ||= session[:current_user_id] && User.find_by(id: session[:current_user_id])
  end

  def user_signed_in?
    Current.user.present?
  end
end