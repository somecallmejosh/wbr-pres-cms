require "application_system_test_case"

class GalleriesTest < ApplicationSystemTestCase
  # Visitor viewing

  test "visitor can view galleries index" do
    visit galleries_url
    assert_text "Photo Galleries"
    assert_text galleries(:worship).title
  end

  test "visitor can view a published gallery" do
    gallery = galleries(:worship)
    visit gallery_url(gallery)
    assert_text gallery.title
  end

  test "visitor does not see admin buttons on index" do
    visit galleries_url
    assert_no_text "New Gallery"
  end

  # Admin actions

  test "admin sees New Gallery button" do
    sign_in_as_admin
    visit galleries_url
    assert_text "New Gallery"
  end

  test "admin can create a gallery" do
    sign_in_as_admin
    visit new_gallery_url
    fill_in "Title", with: "System Test Gallery"
    click_button "Create Gallery"
    assert_text "System Test Gallery"
  end

  test "admin can edit a gallery" do
    sign_in_as_admin
    gallery = galleries(:worship)
    visit edit_gallery_url(gallery)
    fill_in "Title", with: "Updated Gallery Title"
    click_button "Update Gallery"
    assert_text "Updated Gallery Title"
  end

  test "admin can delete a gallery" do
    sign_in_as_admin
    gallery = galleries(:community)
    visit gallery_url(gallery)
    accept_confirm { click_button "Delete" }
    assert_current_path galleries_path
  end
end
