class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def user_signed_in?
    current_user.present?
  end
  helper_method :user_signed_in?

  def current_user
    return @user if defined?(@user)

    if cookies.encrypted[:user_id]
      @user = User.find_by(id: cookies.encrypted[:user_id])
      unless @user
        cookies.delete(:user_id)
      end
    else
      @user = nil
    end

    @user
  end
  helper_method :current_user
end
