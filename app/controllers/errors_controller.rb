class ErrorsController < ApplicationController
  allow_unauthenticated_access only: %i[ not_found internal_server_error ]

  def not_found
    render status: :not_found
  end

  def internal_server_error
    render status: :internal_server_error
  end
end
