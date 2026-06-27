class PagesController < ApplicationController
  allow_unauthenticated_access only: %i[ home contact submit_contact about accessibility ]
  def home
    @weekly_events = Event.this_week.limit(2)
    @birthdays = Member.birthdays_this_month
    @featured_gallery = Gallery.published.ordered.includes(:images).first
    @featured_images = @featured_gallery ? @featured_gallery.images.first(10) : []
  end

  def contact
  end

  def submit_contact
    name    = params[:name].to_s.strip
    email   = params[:email].to_s.strip
    message = params[:message].to_s.strip

    if name.blank? || email.blank? || message.blank?
      flash[:alert] = "Please fill in all fields before sending."
      redirect_to pages_contact_path and return
    end

    ContactMailer.inquiry(name: name, email: email, message: message).deliver_later
    flash[:notice] = "Thank you! Your message has been sent. We'll be in touch soon."
    redirect_to pages_contact_path
  end

  def about
  end

  def accessibility
  end

  def specifications
  end

  def admin_guide
  end

  def dashboard
    @upcoming_events = Event.upcoming.count
    @gallery_count = Gallery.count
    @member_count = Member.count
    @photo_count = Image.count
  end
end
