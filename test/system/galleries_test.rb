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
    click_button "Save gallery"
    assert_text "System Test Gallery"
  end

  test "admin can open the upload modal while building a gallery" do
    sign_in_as_admin
    visit new_gallery_url

    click_on "Upload images"

    # The shared upload modal opens in gallery context with its dropzone.
    assert_selector "dialog[data-controller='modal']", visible: true
    assert_text "Upload photos"
    assert_selector "input[type='file']#files", visible: :all
  end

  test "admin can stage and unstage photos while creating a gallery" do
    sign_in_as_admin
    image = images(:sanctuary)
    visit new_gallery_url

    assert_text "No photos in this gallery yet"

    # Tap a library photo (the checkbox is sr-only — click its label) to stage it.
    tap_photo = -> { find("input[data-image-id='#{image.id}']", visible: :all).find(:xpath, "ancestor::label[1]").click }

    tap_photo.call
    assert_selector "[data-gallery-editor-target='list'] [data-image-id='#{image.id}']"
    assert_selector "[data-gallery-editor-target='count']", text: "1"

    # Remove it again from the staged list — back to empty.
    within "[data-gallery-editor-target='list'] [data-image-id='#{image.id}']" do
      click_button "Remove"
    end
    assert_text "No photos in this gallery yet"

    # Re-stage and save — the image persists with the new gallery.
    tap_photo.call
    fill_in "Title", with: "Staged Gallery"
    click_button "Save gallery"

    assert_text "Staged Gallery"
    assert Gallery.find_by(title: "Staged Gallery").images.exists?(image.id)
  end

  test "admin can reorder staged photos while creating a gallery" do
    sign_in_as_admin
    sanctuary = images(:sanctuary)
    fellowship = images(:fellowship_hall)
    visit new_gallery_url

    photo = ->(image) { find("input[data-image-id='#{image.id}']", visible: :all).find(:xpath, "ancestor::label[1]") }

    # Stage fellowship first, then sanctuary -> list order [fellowship, sanctuary].
    photo.call(fellowship).click
    photo.call(sanctuary).click
    assert_selector "[data-gallery-editor-target='count']", text: "2"

    # Keyboard-reorder sanctuary up to the top -> [sanctuary, fellowship].
    row = find("[data-gallery-editor-target='list'] [data-image-id='#{sanctuary.id}']")
    row.click
    row.send_keys(:arrow_up)

    fill_in "Title", with: "Ordered Gallery"
    click_button "Save gallery"

    assert_text "Ordered Gallery"
    gallery = Gallery.find_by(title: "Ordered Gallery")
    assert_equal [ sanctuary.id, fellowship.id ], gallery.images.map(&:id)
  end

  test "admin can edit a gallery" do
    sign_in_as_admin
    gallery = galleries(:worship)
    visit edit_gallery_url(gallery)
    fill_in "Title", with: "Updated Gallery Title"
    click_button "Save gallery"
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
