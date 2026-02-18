# Admin user
User.find_or_create_by!(email_address: "josh@thebrileys.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
end
