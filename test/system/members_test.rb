require "application_system_test_case"

class MembersTest < ApplicationSystemTestCase
  # Visitor blocked

  test "visitor is redirected from members index to login" do
    visit members_url
    assert_current_path new_session_path
  end

  test "visitor is redirected from member show to login" do
    visit member_url(members(:alice))
    assert_current_path new_session_path
  end

  # Admin CRUD

  test "admin can view members list" do
    sign_in_as_admin
    visit members_url
    assert_text "Members"
    assert_text members(:alice).full_name
  end

  test "admin can view member detail" do
    sign_in_as_admin
    visit member_url(members(:alice))
    assert_text members(:alice).full_name
  end

  test "admin can create a member" do
    sign_in_as_admin
    visit new_member_url
    fill_in "First name", with: "Test"
    fill_in "Last name", with: "Person"
    click_button "Save member"
    assert_text "Test Person"
  end

  test "admin can edit a member" do
    sign_in_as_admin
    member = members(:alice)
    visit edit_member_url(member)
    fill_in "First name", with: "Alicia"
    click_button "Save member"
    assert_text "Alicia"
  end

  test "admin can delete a member" do
    sign_in_as_admin
    member = members(:charlie)
    visit member_url(member)
    accept_confirm { click_button "Delete" }
    assert_current_path members_path
  end
end
