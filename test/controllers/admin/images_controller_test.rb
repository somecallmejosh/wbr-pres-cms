require "test_helper"
require "webmock/minitest"

class Admin::ImagesControllerTest < ActionDispatch::IntegrationTest
  CLOUDINARY_UPLOAD_RESPONSE = {
    "public_id" => "wbr-pres-cms/uploaded_photo",
    "secure_url" => "https://res.cloudinary.com/dwjulenau/image/upload/wbr-pres-cms/uploaded_photo.jpg",
    "width" => 1200,
    "height" => 800,
    "format" => "jpg",
    "bytes" => 204800
  }.freeze

  setup do
    @user = users(:one)
    @image = images(:sanctuary)
    sign_in_as(@user)

    # Stub all Cloudinary HTTP requests
    stub_request(:post, /api\.cloudinary\.com/).to_return(
      status: 200,
      body: CLOUDINARY_UPLOAD_RESPONSE.to_json,
      headers: { "Content-Type" => "application/json" }
    )
    stub_request(:post, /api\.cloudinary\.com.*destroy/).to_return(
      status: 200,
      body: { "result" => "ok" }.to_json,
      headers: { "Content-Type" => "application/json" }
    )
  end

  # Auth tests

  test "index requires authentication" do
    sign_out
    get admin_images_url
    assert_redirected_to new_session_path
  end

  test "new requires authentication" do
    sign_out
    get new_admin_image_url
    assert_redirected_to new_session_path
  end

  test "create requires authentication" do
    sign_out
    post admin_images_url, params: { files: [fixture_file_upload("test_image.jpg", "image/jpeg")] }
    assert_redirected_to new_session_path
  end

  test "destroy requires authentication" do
    sign_out
    delete admin_image_url(@image)
    assert_redirected_to new_session_path
  end

  # CRUD tests

  test "should get index" do
    get admin_images_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_image_url
    assert_response :success
  end

  test "should create a single image via Cloudinary upload" do
    temp_file = Tempfile.new(["test_image", ".jpg"])
    temp_file.write("fake image data")
    temp_file.rewind

    assert_difference("Image.count", 1) do
      post admin_images_url, params: {
        files: [Rack::Test::UploadedFile.new(temp_file.path, "image/jpeg")]
      }
    end

    assert_redirected_to admin_images_path
    assert_equal "wbr-pres-cms/uploaded_photo", Image.last.cloudinary_public_id
  ensure
    temp_file&.close
    temp_file&.unlink
  end

  test "should create multiple images in one upload" do
    responses = [
      { status: 200, body: CLOUDINARY_UPLOAD_RESPONSE.merge("public_id" => "wbr-pres-cms/photo_1").to_json, headers: { "Content-Type" => "application/json" } },
      { status: 200, body: CLOUDINARY_UPLOAD_RESPONSE.merge("public_id" => "wbr-pres-cms/photo_2").to_json, headers: { "Content-Type" => "application/json" } }
    ]
    WebMock.stub_request(:post, /api\.cloudinary\.com/).to_return(*responses)

    files = 2.times.map do |i|
      tmp = Tempfile.new(["test_#{i}", ".jpg"])
      tmp.write("fake image data")
      tmp.rewind
      tmp
    end

    assert_difference("Image.count", 2) do
      post admin_images_url, params: {
        files: files.map { |f| Rack::Test::UploadedFile.new(f.path, "image/jpeg") }
      }
    end

    assert_redirected_to admin_images_path
    assert_match "2 images uploaded successfully", flash[:notice]
  ensure
    files&.each { |f| f.close; f.unlink }
  end

  test "should silently cap at 20 files" do
    # Build 21 identical stubs — only 20 should be processed
    responses = 20.times.map do |i|
      { status: 200, body: CLOUDINARY_UPLOAD_RESPONSE.merge("public_id" => "wbr-pres-cms/cap_#{i}").to_json, headers: { "Content-Type" => "application/json" } }
    end
    WebMock.stub_request(:post, /api\.cloudinary\.com/).to_return(*responses)

    files = 21.times.map do |i|
      tmp = Tempfile.new(["cap_#{i}", ".jpg"])
      tmp.write("fake image data")
      tmp.rewind
      tmp
    end

    assert_difference("Image.count", 20) do
      post admin_images_url, params: {
        files: files.map { |f| Rack::Test::UploadedFile.new(f.path, "image/jpeg") }
      }
    end

    assert_redirected_to admin_images_path
  ensure
    files&.each { |f| f.close; f.unlink }
  end

  test "should render new with error when no files are provided" do
    post admin_images_url, params: {}
    assert_response :unprocessable_entity
  end

  # Sync tests

  test "sync requires authentication" do
    sign_out
    post sync_admin_images_url
    assert_redirected_to new_session_path
  end

  test "sync adds images found on Cloudinary that are missing locally" do
    stub_cloudinary_resources([
      cloudinary_resource("wbr-pres-cms/sanctuary_photo"),
      cloudinary_resource("wbr-pres-cms/fellowship_hall"),
      cloudinary_resource("wbr-pres-cms/new_from_cloudinary")
    ])

    assert_difference("Image.count", 1) do
      post sync_admin_images_url
    end

    assert_redirected_to admin_images_path
    assert_match "1 image added", flash[:notice]
    assert Image.exists?(cloudinary_public_id: "wbr-pres-cms/new_from_cloudinary")
  end

  test "sync removes local records for images deleted from Cloudinary" do
    # Cloudinary only has sanctuary_photo; fellowship_hall is gone
    stub_cloudinary_resources([
      cloudinary_resource("wbr-pres-cms/sanctuary_photo")
    ])

    assert_difference("Image.count", -1) do
      post sync_admin_images_url
    end

    assert_redirected_to admin_images_path
    assert_match "1 stale record removed", flash[:notice]
    assert_not Image.exists?(cloudinary_public_id: "wbr-pres-cms/fellowship_hall")
  end

  test "sync reports up to date when nothing has changed" do
    stub_cloudinary_resources([
      cloudinary_resource("wbr-pres-cms/sanctuary_photo"),
      cloudinary_resource("wbr-pres-cms/fellowship_hall")
    ])

    assert_no_difference("Image.count") do
      post sync_admin_images_url
    end

    assert_redirected_to admin_images_path
    assert_match "already up to date", flash[:notice]
  end

  test "sync redirects with alert on Cloudinary API error" do
    stub_request(:get, /api\.cloudinary\.com.*resources/).to_return(
      status: 401,
      body: { "error" => { "message" => "Invalid credentials" } }.to_json,
      headers: { "Content-Type" => "application/json" }
    )

    post sync_admin_images_url
    assert_redirected_to admin_images_path
    assert_match "Cloudinary sync failed", flash[:alert]
  end

  test "should destroy image" do
    WebMock.stub_request(:post, /api\.cloudinary\.com/).to_return(
      status: 200,
      body: { "result" => "ok" }.to_json,
      headers: { "Content-Type" => "application/json" }
    )

    assert_difference("Image.count", -1) do
      delete admin_image_url(@image)
    end

    assert_redirected_to admin_images_url
  end

  private

  def cloudinary_resource(public_id)
    {
      "public_id" => public_id,
      "secure_url" => "https://res.cloudinary.com/dwjulenau/image/upload/#{public_id}.jpg",
      "width" => 1200,
      "height" => 800,
      "format" => "jpg",
      "bytes" => 204800
    }
  end

  def stub_cloudinary_resources(resources)
    stub_request(:get, /api\.cloudinary\.com.*resources/).to_return(
      status: 200,
      body: { "resources" => resources }.to_json,
      headers: { "Content-Type" => "application/json" }
    )
  end
end
