module GalleriesHelper
  # schema.org/ImageGallery structured data for a gallery detail page. Lists the
  # gallery's photos (capped — search engines don't need every frame) so a share
  # or search result understands it's a photo collection.
  def gallery_json_ld(gallery)
    photos = gallery.images.first(12)
    data = {
      "@context" => "https://schema.org",
      "@type" => "ImageGallery",
      "name" => gallery.title,
      "url" => gallery_url(gallery),
      "image" => photos.any? ? photos.map { |img| img.display_url(width: 1600) } : og_image_url(gallery.cover_image),
      "isPartOf" => {
        "@type" => "WebSite",
        "name" => "West Baton Rouge Presbyterian Church",
        "url" => root_url
      }
    }
    if gallery.description.present?
      data["description"] = truncate(strip_tags(gallery.description).squish, length: 300)
    end
    data
  end
end
