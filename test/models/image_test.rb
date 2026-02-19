require "test_helper"

class ImageTest < ActiveSupport::TestCase
  # Validations -- cloudinary_public_id

  test "valid with all required attributes" do
    image = Image.new(
      cloudinary_public_id: "wbr-pres-cms/test_photo",
      url: "https://res.cloudinary.com/example/image/upload/test.jpg"
    )
    assert image.valid?
  end

  test "invalid without cloudinary_public_id" do
    image = images(:sanctuary)
    image.cloudinary_public_id = nil
    assert_not image.valid?
    assert_includes image.errors[:cloudinary_public_id], "can't be blank"
  end

  test "invalid with duplicate cloudinary_public_id" do
    image = Image.new(
      cloudinary_public_id: images(:sanctuary).cloudinary_public_id,
      url: "https://res.cloudinary.com/example/image/upload/other.jpg"
    )
    assert_not image.valid?
    assert_includes image.errors[:cloudinary_public_id], "has already been taken"
  end

  # Validations -- url

  test "invalid without url" do
    image = images(:sanctuary)
    image.url = nil
    assert_not image.valid?
    assert_includes image.errors[:url], "can't be blank"
  end

  # Validations -- title

  test "valid with blank title" do
    image = Image.new(
      cloudinary_public_id: "wbr-pres-cms/no_title",
      url: "https://res.cloudinary.com/example/image/upload/no_title.jpg",
      title: ""
    )
    assert image.valid?
  end

  test "invalid with title over 255 characters" do
    image = images(:sanctuary)
    image.title = "a" * 256
    assert_not image.valid?
    assert_includes image.errors[:title], "is too long (maximum is 255 characters)"
  end

  # Validations -- alt_text

  test "valid with blank alt_text" do
    image = Image.new(
      cloudinary_public_id: "wbr-pres-cms/no_alt",
      url: "https://res.cloudinary.com/example/image/upload/no_alt.jpg",
      alt_text: ""
    )
    assert image.valid?
  end

  test "invalid with alt_text over 255 characters" do
    image = images(:sanctuary)
    image.alt_text = "a" * 256
    assert_not image.valid?
    assert_includes image.errors[:alt_text], "is too long (maximum is 255 characters)"
  end

  # URL generation methods

  test "thumbnail_url returns a Cloudinary URL with the public_id" do
    image = images(:sanctuary)
    url = image.thumbnail_url
    assert_includes url, image.cloudinary_public_id
  end

  test "thumbnail_url accepts custom dimensions" do
    image = images(:sanctuary)
    url = image.thumbnail_url(width: 100, height: 100)
    assert_includes url, "w_100"
    assert_includes url, "h_100"
  end

  test "display_url returns a Cloudinary URL with the public_id" do
    image = images(:sanctuary)
    url = image.display_url
    assert_includes url, image.cloudinary_public_id
  end

  test "display_url accepts custom width" do
    image = images(:sanctuary)
    url = image.display_url(width: 400)
    assert_includes url, "w_400"
  end

  # Associations

  test "has many events" do
    assert_respond_to images(:sanctuary), :events
  end
end
