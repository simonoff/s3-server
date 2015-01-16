class ApplicationController < ActionController::Base
  respond_to :xml

  include ErrorManager

  def routing_error
    fail ActionController::RoutingError.new(params[:path])
  end
end
