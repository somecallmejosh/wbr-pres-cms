require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "user can sign in with valid credentials" do
    visit new_session_url
    fill_in "Enter your email address", with: users(:one).email_address
    fill_in "Enter your password", with: "password"
    click_button "Sign in"
    assert_current_path root_path
  end

  test "user can sign out" do
    sign_in_as_admin
    visit root_url
    click_on "Log Out"
    assert_current_path new_session_path
  end

  test "sign in with wrong password shows error" do
    visit new_session_url
    fill_in "Enter your email address", with: users(:one).email_address
    fill_in "Enter your password", with: "wrongpassword"
    click_button "Sign in"
    assert_text "Try another email address or password"
  end

  test "visiting protected page redirects unauthenticated user to login" do
    visit new_event_url
    assert_current_path new_session_path
  end

  test "visiting members page redirects unauthenticated user to login" do
    visit members_url
    assert_current_path new_session_path
  end

  test "admin navigation links appear after sign in" do
    sign_in_as_admin
    visit root_url
    assert_text "Members"
    assert_text "Image Library"
  end

  test "admin navigation links hidden when signed out" do
    visit root_url
    assert_no_text "Image Library"
  end
end
