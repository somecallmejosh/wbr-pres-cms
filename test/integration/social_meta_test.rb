require "test_helper"

# Verifies that public pages emit absolute Open Graph / Twitter share images,
# meaningful descriptions, and JSON-LD structured data so links unfurl correctly
# when shared on social media and are understood by search engines.
class SocialMetaTest < ActionDispatch::IntegrationTest
  test "home page emits the Cloudinary site share image (absolute https)" do
    get root_url

    assert_match %r{property="og:image"[^>]+content="https://res\.cloudinary\.com/[^"]+image012\.jpg},
      @response.body
    assert_match %r{name="twitter:image"[^>]+content="https://res\.cloudinary\.com/[^"]+image012\.jpg},
      @response.body
    assert_select "meta[name='description']"
  end

  test "every public page carries baseline Church JSON-LD" do
    [ root_url, events_url, galleries_url, calendar_url,
      pages_about_url, pages_contact_url, accessibility_statement_url ].each do |url|
      get url
      ld = json_ld_blocks
      assert ld.any? { |d| d["@type"] == "Church" },
        "expected Church JSON-LD on #{url}"
    end
  end

  test "event page uses the event image and emits Event JSON-LD" do
    image = images(:sanctuary)
    event = events(:this_week_education)
    event.update!(image: image)

    get event_url(event)

    assert_select "meta[property='og:image'][content*=?]", image.cloudinary_public_id
    ld = json_ld_blocks
    event_ld = ld.find { |d| d["@type"] == "Event" }
    assert event_ld, "expected Event JSON-LD"
    assert_equal event.title, event_ld["name"]
    assert event_ld["startDate"].present?
    assert_equal "https://schema.org/EventScheduled", event_ld["eventStatus"]
  end

  test "event without an image falls back to the site share image" do
    event = events(:this_week_education)
    event.update!(image: nil)

    get event_url(event)

    assert_match %r{og:image[^>]+content="https://res\.cloudinary\.com/[^"]+image012\.jpg},
      @response.body
  end

  test "gallery page emits ImageGallery JSON-LD" do
    gallery = galleries(:worship)

    get gallery_url(gallery)

    ld = json_ld_blocks
    gallery_ld = ld.find { |d| d["@type"] == "ImageGallery" }
    assert gallery_ld, "expected ImageGallery JSON-LD"
    assert_equal gallery.title, gallery_ld["name"]
  end

  private

  # Parse every <script type="application/ld+json"> block on the page into Hashes.
  def json_ld_blocks
    css_select("script[type='application/ld+json']").map { |node| JSON.parse(node.text) }
  end
end
