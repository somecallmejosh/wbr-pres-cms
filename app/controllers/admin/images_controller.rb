class Admin::ImagesController < ApplicationController
  MAX_UPLOAD_COUNT = 20
  CLOUDINARY_FOLDER = "wbr-pres-cms"

  before_action :set_image, only: %i[destroy]

  def index
    @images = Image.order(created_at: :desc)
  end

  def new
  end

  def create
    files = Array(params[:files]).first(MAX_UPLOAD_COUNT)

    if files.empty?
      flash.now[:alert] = "Please select at least one image to upload."
      render :new, status: :unprocessable_entity
      return
    end

    uploaded = 0
    failed = []

    files.each do |file|
      result = Cloudinary::Uploader.upload(
        file,
        folder: CLOUDINARY_FOLDER,
        resource_type: "image",
        allowed_formats: %w[jpg jpeg png webp gif]
      )

      image = Image.new(
        cloudinary_public_id: result["public_id"],
        url: result["secure_url"],
        width: result["width"],
        height: result["height"],
        format: result["format"],
        bytes: result["bytes"]
      )

      image.save ? uploaded += 1 : failed << file.original_filename
    rescue Cloudinary::Api::Error => e
      failed << "#{file.original_filename}: #{e.message}"
    end

    if uploaded > 0
      notice = "#{uploaded} #{uploaded == 1 ? "image" : "images"} uploaded successfully."
      notice += " #{failed.size} #{failed.size == 1 ? "file" : "files"} failed." if failed.any?
      redirect_to admin_images_path, notice: notice
    else
      flash.now[:alert] = "Upload failed: #{failed.join("; ")}"
      render :new, status: :unprocessable_entity
    end
  end

  def sync
    cloudinary_resources = fetch_all_cloudinary_resources
    cloudinary_ids = cloudinary_resources.map { |r| r["public_id"] }
    existing_ids = Image.pluck(:cloudinary_public_id)

    added = 0
    (cloudinary_ids - existing_ids).each do |public_id|
      resource = cloudinary_resources.find { |r| r["public_id"] == public_id }
      Image.create!(
        cloudinary_public_id: resource["public_id"],
        url: resource["secure_url"],
        width: resource["width"],
        height: resource["height"],
        format: resource["format"],
        bytes: resource["bytes"]
      )
      added += 1
    end

    removed = Image.where(cloudinary_public_id: existing_ids - cloudinary_ids).destroy_all.count

    if added == 0 && removed == 0
      notice = "Library is already up to date."
    else
      parts = []
      parts << "#{added} #{added == 1 ? "image" : "images"} added" if added > 0
      parts << "#{removed} stale #{removed == 1 ? "record" : "records"} removed" if removed > 0
      notice = "Sync complete — #{parts.join(", ")}."
    end

    redirect_to admin_images_path, notice: notice
  rescue Cloudinary::Api::Error => e
    redirect_to admin_images_path, alert: "Cloudinary sync failed: #{e.message}"
  end

  def destroy
    Cloudinary::Uploader.destroy(@image.cloudinary_public_id)
    @image.destroy!
    redirect_to admin_images_path, notice: "Image was successfully deleted.", status: :see_other
  rescue Cloudinary::Api::Error => e
    redirect_to admin_images_path, alert: "Could not delete image from Cloudinary: #{e.message}", status: :see_other
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end

  def fetch_all_cloudinary_resources
    resources = []
    next_cursor = nil

    loop do
      opts = {
        type: "upload",
        prefix: CLOUDINARY_FOLDER,
        max_results: 500,
        resource_type: "image"
      }
      opts[:next_cursor] = next_cursor if next_cursor

      result = Cloudinary::Api.resources(**opts)
      resources.concat(result["resources"] || [])
      next_cursor = result["next_cursor"]
      break unless next_cursor
    end

    resources
  end
end
