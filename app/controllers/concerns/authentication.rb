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

  # authenticate_user method can be called to ensure an anonymous user cannot access a page that requires a user to be logged in.
  # We'll need this when we build the page allowing a user to edit or delete their profile.
  def authenticate_user!
    store_location
    redirect_to login_path, alert: "You need to login to access this page." unless user_signed_in?
  end

  def forget(user)
    cookies.delete :remember_token
    user.regenerate_remember_token
  end

  def remember(user)
    user.regenerate_remember_token
    cookies.permanent.encrypted[:remember_token] = user.remember_token
  end

  private

  # The current_user methods returns a User and sets it as the user on the Current class we created
  # We use `memoization` to avoid fetching the User each time on the Current class we created
  # We call before_action filter so that we have access to the current user before each request.
  # We also add this as `helper_method` so that we have access to `current_user` in the view.
  def current_user
    Current.user ||= if session[:current_user_id].present?
      User.find_by(id: session[:current_user_id])
    elsif cookies.permanent.encrypted[:remember_token].present?
      User.find_by(remember_token: cookies.permanent.encrypted[:remember_token])
  end

  def user_signed_in?
    Current.user.present?
  end

  # The store_location method stores the request.original_url in the session so it can be retrieve later.
  # We only do this if the request made was a get request. We also call request.local? to ensure
  # it was a local request. This prevents redirecting to an external application
  # We call store_location in the authenticate_user! method so that we can save the path to
  # the page the user was trying to visit before they were redirected to the login page.
  def store_location
    session[:user_return_to] = request.original_url if request.get? && request.local?
  end
end