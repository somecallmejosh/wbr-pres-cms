class PagesController < ApplicationController
  allow_unauthenticated_access only: %i[ home contact about ]
  def home
  end

  def contact
  end

  def about
  end
end
