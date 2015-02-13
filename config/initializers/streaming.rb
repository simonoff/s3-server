module ActionController
  module Live
    class Buffer
      def write(string)
        unless @response.committed?
          @response.headers['Cache-Control'] = 'no-cache'
          # @response.headers.delete 'Content-Length'
        end

        super

        unless connected?
          @buf.clear
          fail ClientDisconnected.new 'client disconnected' unless @ignore_disconnect
        end
      end

      def connected?
        !@aborted
      end
    end
  end
end
