# Action Cable Status - Real-time User Status with Rails 8

A real-time user status application built with Rails 8, Action Cable, and Turbo Streams. This project demonstrates how to track and display user online/offline status in real-time across multiple browser sessions.

## Inspiration & Credits

This project is inspired by the excellent work of **Phawk** (Pete Hawkins) from his tutorial on Action Cable online status tracking:

- **Original Repository**: https://github.com/phawk/action-cable-online-status
- **YouTube Tutorial**: https://youtu.be/KtOEoOMEdoE?si=92KImT2szrBdoVXZ
- **Channel**: Rapid Ruby

**Full credit goes to Phawk for the original concept and implementation.** His original code was built with Rails 7.0.4 and Ruby 3.1.0. This version has been updated for Rails 8 and Ruby 3.4.4, incorporating the latest Rails features like Solid Cable, Solid Queue, and updated Action Cable patterns.

## Project Setup

This project was created with:

```bash
rails new action-cable-status --css=tailwind
```

## Technology Stack

- **Rails 8.0.2**
- **Ruby 3.4.4**
- **SQLite3** (for database and Action Cable message storage)
- **Tailwind CSS 4.1** for styling
- **Turbo Rails** & **Stimulus** for reactive UI
- **Action Cable** with **Solid Cable** for WebSocket connections

> **Note**: While this demo uses SQLite for storage (including Action Cable message storage via Solid Cable), you can easily port this to PostgreSQL or Redis if needed. SQLite with Solid Cable is perfectly suitable for production Rails 8 applications.

## Features

- Real-time user status tracking (online/offline)
- Live status updates across all browser sessions
- Last seen timestamps
- Simple authentication system (username-based)
- Responsive design with Tailwind CSS
- Avatar placeholders with generated images

## Quick Start

Want to test this right away? Here's the fastest way:

1. **Clone and setup**
   ```bash
   git clone git@github.com:spaquet/action-cable-online-status.git
   cd action-cable-status
   bundle install
   ```

2. **Prepare database** (creates tables, runs migrations, and seeds data)
   ```bash
   rails db:prepare
   ```

3. **Start the server**
   ```bash
   ./bin/dev
   ```

4. **Test real-time updates**
   - Open http://localhost:3000 or http://127.0.0.1:3000
   - Sign in with any username: `paul`, `amy`, `sarah`, `shan`, `emily`, `bert`, `alice`, `nate`, `gloria`, `gustav`
   - Open another browser window/tab and sign in with a different username
   - Watch the status updates happen in real-time! 🎉

## How It Works

This application demonstrates several key Rails 8 concepts working together:

### 1. User Model (`app/models/user.rb`)

The `User` model handles status tracking and broadcasting updates:

```ruby
class User < ApplicationRecord
  after_create_commit { broadcast_prepend_to("online_users", target: "online-users") }
  after_update_commit { broadcast_replace_to("online_users") }
  after_destroy_commit { broadcast_remove_to("online_users") }

  def online?
    status == "online"
  end

  def offline?
    !online?
  end
end
```

**Key Features:**
- **Status tracking**: Uses a `status` field (online/offline) and `last_online_at` timestamp
- **Automatic broadcasting**: Rails model callbacks automatically broadcast Turbo Stream updates
- **Helper methods**: Convenient `online?` and `offline?` methods for status checking

**Database Schema:**
```ruby
create_table :users do |t|
  t.string :username, null: false
  t.string :status, null: false, default: "offline"
  t.datetime :last_online_at
  t.timestamps
end
```

### 2. Action Cable Connection (`app/channels/application_cable/connection.rb`)

Handles WebSocket authentication and user identification:

```ruby
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        if verified_user = User.find_by(id: cookies.encrypted[:user_id])
          verified_user
        else
          nil  # Allow anonymous connections
        end
      end
  end
end
```


### 3. Online Channel (`app/channels/online_channel.rb`)

Manages user status updates via WebSocket:

```ruby
class OnlineChannel < ApplicationCable::Channel
  def subscribed
    stream_from "online_users"
    current_user&.update!(status: "online", last_online_at: Time.current)
  end

  def unsubscribed
    current_user&.update!(status: "offline")
  end
end
```

### 4. Sessions Controller (`app/controllers/sessions_controller.rb`)

Handles user authentication and status management:

```ruby
class SessionsController < ApplicationController
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
```

### 5. Frontend Integration

#### JavaScript Channel (`app/javascript/channels/online_channel.js`)

```javascript
import consumer from "channels/consumer"

consumer.subscriptions.create("OnlineChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
  }
});
```

#### Turbo Stream Integration (`app/views/layouts/application.html.erb`)

```erb
<%= turbo_stream_from "online_users" %>
```

This single line enables real-time updates by connecting the page to the "online_users" Turbo Stream.

#### User Display (`app/views/users/_user.html.erb`)

```erb
<li class="col-span-1 flex flex-col divide-y divide-gray-200 rounded-lg bg-white text-center shadow" id="<%= dom_id(user) %>">
  <div class="flex flex-1 flex-col p-8">
    <%= image_tag "https://ui-avatars.com/api/?name=#{user.username}&background=6366f1&color=fff&size=128", 
        alt: user.username, 
        class: "mx-auto h-32 w-32 flex-shrink-0 rounded-full" %>
    <h3 class="mt-6 text-sm font-medium text-gray-900">@<%= user.username %></h3>
    <dl class="mt-1 flex flex-grow flex-col justify-between">
      <dt class="sr-only">Active?</dt>
      <dd class="mt-3">
        <% if user.online? %>
          <span class="rounded-full bg-green-100 px-2 py-1 text-xs font-medium text-green-800">Online now</span>
        <% elsif user.last_online_at.present? %>
          <span class="rounded-full bg-gray-100 px-2 py-1 text-xs font-medium text-gray-800">Last seen <%= time_ago_in_words user.last_online_at %> ago</span>
        <% else %>
          <span class="rounded-full bg-gray-100 px-2 py-1 text-xs font-medium text-gray-800">Never signed in</span>
        <% end %>
      </dd>
    </dl>
  </div>
</li>
```

## Rails 8 Specific Features

This project leverages Rails 8 innovations:

### Solid Cable
Instead of Redis, this uses **Solid Cable** for Action Cable message storage:

```yaml
# config/cable.yml
production:
  adapter: solid_cable
  connects_to:
    database:
      writing: cable
```

This stores WebSocket messages in SQLite, eliminating the need for a separate Redis instance.


## How Real-time Updates Work

The magic happens through the combination of several technologies:

1. **Action Cable WebSocket Connection**: When a user loads the page, JavaScript automatically connects to the `OnlineChannel`

2. **Status Updates**: When the WebSocket connects, the channel updates the user's status to "online"

3. **Model Callbacks**: The User model's `after_update_commit` callback automatically broadcasts a Turbo Stream update

4. **Turbo Stream Reception**: All connected browsers receive the update via `turbo_stream_from "online_users"`

5. **DOM Updates**: Turbo automatically updates the specific user's card in the DOM without page refresh

This creates a seamless real-time experience where status changes are instantly visible across all connected sessions.

## License

This code is freely available for reuse and abuse. No warranties provided. All credit for the original concept goes to **Phawk** and his excellent Rapid Ruby tutorials.

## Contributing

Feel free to fork, modify, and improve this application. If you create something cool with it, share it with the community!