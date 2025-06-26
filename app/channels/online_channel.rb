class OnlineChannel < ApplicationCable::Channel
  def subscribed
    # Stream from the same channel name that the model broadcasts to
    stream_from "online_users"

    current_user&.update!(status: "online", last_online_at: Time.current)
    super
  end

  def unsubscribed
    current_user&.update!(status: "offline")
    super
  end
end
