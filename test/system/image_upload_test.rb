require "application_system_test_case"

class ImageUploadTest < ApplicationSystemTestCase
  setup { sign_in_as_admin }

  test "choosing photos shows live thumbnails before upload" do
    visit new_admin_image_url

    assert_no_selector "[data-upload-preview-target='preview']", visible: true
    attach_file "files", file_fixture("test_image.jpg").to_s

    # A thumbnail of the chosen photo appears, named, with a live count.
    assert_selector "[data-upload-preview-target='list'] img", count: 1
    assert_text "test_image.jpg"
    assert_selector "[data-upload-preview-target='count']", text: "1"
  end

  test "a pending photo can be removed before upload" do
    visit new_admin_image_url
    attach_file "files", file_fixture("test_image.jpg").to_s
    assert_selector "[data-upload-preview-target='list'] img", count: 1

    find("button[aria-label='Remove photo']").click

    assert_no_selector "[data-upload-preview-target='list'] img"
    assert_no_selector "[data-upload-preview-target='preview']", visible: true
  end
end
