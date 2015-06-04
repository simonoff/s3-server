class ApplicationController < ActionController::Base
  include ApplicationHelper
  around_action :retry_on_database_connection_timeout

  include ErrorManager

  def routing_error
    fail ActionController::RoutingError.new(params[:path])
  end

  private

  def retry_on_database_connection_timeout(tries: 5)
    yield
  rescue ActiveRecord::ConnectionTimeoutError
    ActiveRecord::ConnectionAdapters::ConnectionHandler.clear_active_connections!
    sleep 2
    tries -= 1
    retry if tries > 0
    raise
  end
end
