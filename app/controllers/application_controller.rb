class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def user_signed_in?
    current_user.present?
  end
  helper_method :user_signed_in?

  def current_user
    if cookies.encrypted[:user_id]
      @user ||= User.find(cookies.encrypted[:user_id])
    end
  rescue => e
    cookies.delete(:user_id)
  end
  helper_method :current_user
end
