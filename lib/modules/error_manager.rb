module ErrorManager
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError do |e|
      render_custom_error(e)
    end
  end

  def render_custom_error(error)
    e = case error
        when ActiveRecord::RecordNotFound
          { error: Error.create(code: 'NoSuchKey', message: 'The specified key does not exist',
                                resource: error.message),
            status: 404 }
        when ActionController::RoutingError
          { error: Error.create(code: 'NotImplemented', message: '', resource: error.message),
            status: 404 }
        else
          { error: Error.create(code: 'InternalError', message: error.message,
                                resource: error.backtrace.to_s),
            status: 500 }
        end

    @error = e[:error]
    template = Tilt.new('app/views/errors/show.xml.builder')
    response.status = e[:status]
    response.stream.write template.render(self)
  ensure
    response.stream.close unless response.stream.closed?
  end
end
