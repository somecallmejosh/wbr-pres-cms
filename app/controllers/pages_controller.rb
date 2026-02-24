class PagesController < ApplicationController
  allow_unauthenticated_access only: %i[ home contact about accessibility ]
  def home
    @weekly_events = Event.this_week.limit(2)
    @birthdays = Member.birthdays_this_month
  end

  def contact
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
  end
end
