# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Force all browsers to clear session cookies by rotating the secret
# Uncomment the lines below to invalidate all existing cookies across browsers
puts "⚠️  Rotating secret key to invalidate all existing cookies..."
Rails.application.credentials.secret_key_base = SecureRandom.hex(64)
puts "✓ Secret key rotated - all cookies will be invalid on next page load"

puts "Clearing existing users..."
User.delete_all
puts "✓ All users deleted"

puts "Creating users..."

%w[
  paul
  amy
  sarah
  shan
  emily
  bert
  alice
  nate
  gloria
  gustav
].each do |username|
  user = User.where(username: username).first_or_create!
  puts "  ✓ Created user: #{user.username}"
end

puts "Seeding complete!"
