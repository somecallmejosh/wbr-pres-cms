class Image < ApplicationRecord
  has_many :events, dependent: :nullify
  has_many :gallery_images, dependent: :destroy
  has_many :galleries, through: :gallery_images

  validates :cloudinary_public_id, presence: true, uniqueness: true
  validates :url, presence: true
  validates :title, length: { maximum: 255 }, allow_blank: true
  validates :alt_text, length: { maximum: 255 }, allow_blank: true

  # Square/cropped thumbnail. Face-aware fill — see #cover_url.
  def thumbnail_url(width: 200, height: 200)
    cover_url(width: width, height: height)
  end

  # Art-directed crop to an exact width × height (square thumbnails, 16:9 cards,
  # hero bands, gallery covers). Use this for any container with a FIXED aspect
  # ratio so Cloudinary — not the browser's object-cover — does the cropping.
  #
  # gravity "auto:faces" keeps every detected face inside the crop and, when an
  # image has no faces (the sanctuary, a flyer), falls back to content-aware
  # cropping rather than a blind center crop. Combined with q_auto, f_auto
  # (AVIF/WebP), and dpr_auto for crisp retina delivery at minimal bytes.
  def cover_url(width:, height:)
    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      width: width, height: height, crop: :fill, gravity: "auto:faces",
      quality: :auto, fetch_format: :auto, dpr: :auto
    )
  end

  # Full image scaled down to fit within +width+ — never crops, so no face can
  # ever be cut off. Use for lightboxes and any container WITHOUT a fixed aspect
  # ratio. Still optimized: auto format, auto quality, retina DPR.
  def display_url(width: 800)
    Cloudinary::Utils.cloudinary_url(
      cloudinary_public_id,
      width: width, crop: :limit, quality: :auto, fetch_format: :auto, dpr: :auto
    )
  end
end
