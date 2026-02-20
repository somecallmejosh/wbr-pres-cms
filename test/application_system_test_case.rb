require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  def sign_in_as_admin
    visit new_session_path
    fill_in "Enter your email address", with: "one@example.com"
    fill_in "Enter your password", with: "password"
    click_button "Sign in"
    # Wait for redirect to complete and confirm authentication
    assert_current_path root_path
  end
end
