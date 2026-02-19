class PagesController < ApplicationController
  allow_unauthenticated_access only: %i[ home contact about ]
  def home
    @birthdays = Member.birthdays_this_month
  end

  def contact
  end

  def about
  end
end
