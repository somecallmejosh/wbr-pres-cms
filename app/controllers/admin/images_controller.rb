class Admin::ImagesController < ApplicationController
  before_action :set_image, only: %i[destroy]

  def index
    @images = Image.order(created_at: :desc)
  end

  def new
  end

  def create
    result = Cloudinary::Uploader.upload(
      params[:file],
      folder: "wbr-pres-cms",
      resource_type: "image",
      allowed_formats: %w[jpg jpeg png webp gif]
    )

    @image = Image.new(
      cloudinary_public_id: result["public_id"],
      url: result["secure_url"],
      width: result["width"],
      height: result["height"],
      format: result["format"],
      bytes: result["bytes"],
      title: params[:title],
      alt_text: params[:alt_text]
    )

    if @image.save
      redirect_to admin_images_path, notice: "Image was successfully uploaded."
    else
      render :new, status: :unprocessable_entity
    end
  rescue Cloudinary::Api::Error => e
    flash.now[:alert] = "Cloudinary error: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  def destroy
    Cloudinary::Uploader.destroy(@image.cloudinary_public_id)
    @image.destroy!
    redirect_to admin_images_path, notice: "Image was successfully deleted.", status: :see_other
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end
end
