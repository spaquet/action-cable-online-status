class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(username: params[:username])

    if user
      cookies.encrypted[:user_id] = user.id
      redirect_to root_path
    else
      redirect_to new_session_path, notice: "User not found!"
    end
  end

  def destroy
    cookies.delete(:user_id)
    redirect_to new_session_path, notice: "Logged out successfully!"
  end
end
