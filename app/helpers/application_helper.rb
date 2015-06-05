module ApplicationHelper
  def threaded
    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        begin
          yield
        rescue => e
          Thread.current[:error] = e
        end
      end
    end
  end
end
